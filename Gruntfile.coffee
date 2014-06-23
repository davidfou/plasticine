"use strict"
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig

    # Metadata.
    pkg: grunt.file.readJSON("package.json")

    dir:
      source : 'source/'
      bower  : 'components/'
      tmp    : '.tmp/'

    # Task configuration.
    clean:
      tmp  : ["<%= dir.tmp %>"]
      dist : ["dist"]

    copy:
      source:
        files: [
          expand: true
          cwd: "<%= dir.source %>"
          src: ['**', '!**/*.coffee']
          dest: "<%= dir.tmp %>"
        ]
      components:
        files: [
          expand: true
          cwd: "<%= dir.bower %>"
          src: ['**']
          dest: "<%= dir.tmp %><%= dir.bower %>"
        ]

    coffee:
      compile:
        options:
          bare      : true
          sourceMap : false
        expand : true
        cwd    : "<%= dir.source %>"
        src    : ['**/*.coffee']
        dest   : "<%= dir.tmp %>"
        ext    : '.js'

    amdwrap:
      compile:
        expand : true
        cwd    : "<%= dir.tmp %>"
        src    : ['app/**/*.js', 'test/spec/**/*.js']
        dest   : "<%= dir.tmp %>"

    wrap:
      dist:
        expand: true
        cwd: "dist/"
        src: ["**"]
        dest: "dist/"
        options:
          wrapper: [
            """
            (function (root, factory) {
              if (typeof define === 'function' && define.amd) {
                // AMD. Register as an anonymous module.
                define(['plasticine'], factory);
              } else {
                // Browser globals
                root.Plasticine = factory(root);
              }
            }(this, function (global) {
            """
            """
              return require('plasticine');
            }));
            """]

    preprocess:
      javascript:
        options:
          inline: true
        src: ["<%= dir.tmp %>app/**/*.js"]

    watch:
      options:
        livereload: true
        spawn: false
        cwd  : "<%= dir.source %>"
      coffeeFileModified:
        files: "**/*.coffee"
        tasks: ["coffee", "amdwrap:compile", "mocha"]
        options:
          event: ['changed']
      coffeeFileAdded:
        files: "**/*.coffee"
        tasks: ["coffee", "amdwrap:compile", "mocha"]
        options:
          event: ['added']
      coffeeFileDeleted:
        files: "**/*.coffee"
        tasks: ["clean:tmp", "coffee", "mocha"]
        options:
          event: ['deleted']

    requirejs:
      compile:
        options:
          mainConfigFile: "<%= dir.tmp %>app/main.js"
          out: "dist/plasticine.js"
          optimize: 'none'
          cjsTranslate: true
          baseUrl: '<%= dir.tmp %>app'
          paths:
            requireLib: '../components/almond/almond'
          include: ['requireLib']

    usebanner:
      dist:
        options:
          position: 'top'
          linebreak: true
          banner:
            """
            /*!
             * plasticine JavaScript Library <%= pkg.version %>
             * https://github.com/dfournier/plasticine
             *
             * Copyright 2014 David Fournier <fr.david.fournier@gmail.com>
             * Released under the MIT license
             * https://github.com/dfournier/plasticine/blob/master/LICENSE-MIT
             *
             * Date: <%= grunt.template.today() %>
             */
             """
        files:
          src: "dist/plasticine.js"


  grunt.task.loadTasks 'grunt_tasks'
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-mocha"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-amd-wrap"
  grunt.loadNpmTasks "grunt-renaming-wrap"
  grunt.loadNpmTasks 'grunt-preprocess'
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-banner"

  grunt.event.on 'watch', (action, filepath, target) ->
    coffee_files = []
    compile_config = ->
      coffee_files.push 'test/config.coffee'

    coffee_task = 'coffee.compile'
    root_path = grunt.config.get("#{coffee_task}.cwd")
    relative_path = filepath.replace(new RegExp("^#{root_path}"), '')
    ext = grunt.config.get("#{coffee_task}.ext")
    relative_compiled_path = relative_path.replace(/.coffee$/, ext)
    compiled_file = grunt.config.get('dir.tmp') + relative_compiled_path

    if target in ['coffeeFileModified', 'coffeeFileAdded']
      coffee_files.push relative_path
      grunt.config("amdwrap.compile.src", relative_compiled_path)

      # recompile test/config.coffee if a file is added or deleted in test/spec folder
      if action in ['deleted', 'added'] and (/^test\/spec\//).test relative_path
        compile_config()

    if target is 'coffeeFileDeleted'
      grunt.config('clean.tmp', compiled_file)
      compile_config() if (/^test\/spec\//).test relative_path

    grunt.config("#{coffee_task}.src", coffee_files)


  grunt.registerTask "compileTest", ["amdwrap:compile"]

  grunt.registerTask "default", ["test"]
  grunt.registerTask "compile", ["clean:tmp", "coffee", "copy", "preprocess"]
  grunt.registerTask "build", ["clean:dist", "compile", "requirejs", "wrap:dist", "usebanner"]

  grunt.registerTask "start", ["compile", "compileTest", "connect:development", "watch"]

  grunt.registerTask "test", ["compile", "compileTest", "mocha"]
