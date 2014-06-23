module.exports = (grunt) ->

  fs = require('fs')
  serve_application = (req, res, next) ->
    if req.url is '/test/spec/list.json'
      getFiles = (dir) ->
        node =
          name: dir.split('/').pop()
          files: []
          directories: []
        files = fs.readdirSync(dir)
        for file in files
          name = dir + '/' + file
          if fs.statSync(name).isDirectory()
            node.directories.push getFiles(name)
          else
            if (/\.coffee$/).test(file)
              node.files.push file.replace(/\.coffee$/, '.js')
        return node

      main_node = getFiles("#{grunt.config('dir.source')}test/spec")
      res.end JSON.stringify main_node
    else
      next()

  grunt.config.merge
    mocha:
      all:
        options:
          urls     : ['http://localhost:8000/test']
          reporter : 'Progress'
          run      : false
          log      : true
          logErrors: true

    connect:
      development:
        options:
          open: 'http://0.0.0.0:8000/test'
          base: ["./", "<%= dir.tmp %>"]
          middleware: (connect, options, middlewares) ->
            middlewares.push serve_application
            return middlewares
