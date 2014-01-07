"use strict"
module.exports = uRequireConfigMasterDefaults = (grunt) ->

  # Project configuration.
  grunt.initConfig

    # Metadata.
    pkg: grunt.file.readJSON("package.json")
    banner: "/*! <%= pkg.name %> - v<%= pkg.version %> - " + "<%= grunt.template.today(\"yyyy-mm-dd\") %>\n" + "<%= pkg.homepage ? \"* \" + pkg.homepage + \"\\n\" : \"\" %>" + "* Copyright (c) <%= grunt.template.today(\"yyyy\") %> <%= pkg.author.name %>;" + " Licensed <%= _.pluck(pkg.licenses, \"type\").join(\", \") %> */\n"

    # Task configuration.
    clean:
      files: ["dist", ".tmp"]

    copy:
      source:
        files: [
          expand: true
          cwd: 'source/'
          src: ['**', '!**/*.coffee']
          dest: '.tmp'
        ]
      components:
        files: [
          expand: true
          cwd: 'components/'
          src: ['**']
          dest: '.tmp/components'
        ]
      sinon:
        files: [
          expand: true
          cwd: 'node_modules/sinon'
          src: ['**']
          dest: '.tmp/components/sinon'
        ]


    coffee:
      compile:
        options:
          bare : true
        expand : true
        cwd    : 'source/'
        src    : ['**/*.coffee']
        dest   : '.tmp'
        ext    : '.js'

    concat:
      initCustomSinon:
        src  : [
          'vendor/sinon/sinon_start.js'
          'node_modules/sinon/lib/sinon.js'
          'node_modules/sinon/lib/sinon/util/event.js'
          'node_modules/sinon/lib/sinon/util/fake_xml_http_request.js'
          'vendor/sinon/sinon_end.js'
        ]
        dest : '.tmp/components/custom_sinon.js'

    mocha:
      all: ['.tmp/test/index.html']
      options:
        reporter : 'Spec'
        run      : false

    jshint:
      app:
        options:
          jshintrc: "source/app/.jshintrc"

        src: [".tmp/app/**/*.js"]

      test:
        options:
          jshintrc: "source/test/.jshintrc"

        src: [".tmp/test/**/*.js"]

    watch:
      test:
        files: "source/**"
        tasks: "runTest"
        options:
          livereload: true

    requirejs:
      compile:
        options:
          baseUrl: ".tmp/app"
          out: "dist/plasticine.js"
          optimize: 'none'
          cjsTranslate: true
          paths:
            requireLib: '../components/requirejs/require'
          include: ['requireLib']

    'amd-dist':
      all:
        options:
          standalone: false
          env: 'browser'
          exports: 'plasticine'
        files: [
          {
            src:  'dist/plasticine.js'
            dest: 'dist/plasticine-global.js'
          }
        ]

    amdwrap:
      sinon:
        expand: true,
        cwd: "lib/",
        src: ["*.js"],
        dest: "artifacts/amd/"

    connect:
      development:
        options:
          base: '.tmp'

    open:
      development:
        path: 'http://localhost:<%= connect.development.options.port%>/test'

    notify:
      specFailed:
        options:
          message: "Spec failed!"
      specPassed:
        options:
          message: "Spec passed!"

    notify_hooks:
      options:
        enabled: false


  # These plugins provide necessary tasks.
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-mocha"
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-requirejs"
  grunt.loadNpmTasks "grunt-amd-dist"
  grunt.loadNpmTasks "grunt-notify"
  grunt.loadNpmTasks "grunt-open"
  grunt.loadNpmTasks "grunt-amd-wrap"

  grunt.task.run('notify_hooks');

  # Default task.
  grunt.registerTask "default", ["clean", "build", "jshint", "mocha"]
  grunt.registerTask "compile", ["clean", "coffee", "copy", "concat"]
  grunt.registerTask "build", ["compile", "requirejs"]

  # Use those tasks when developping and get test in result in the terminal, as
  # a notification or in a browser
  grunt.registerTask "devTerminal", ["compile", "watch:test"]
  grunt.registerTask "devBrowser", ["connect:development", "open:development", "devTerminal"]


  grunt.registerTask "runTest", ["compile", "mocha"]
