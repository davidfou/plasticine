require.config
  baseUrl: '/app'
  packages: [
    {
      name: 'lodash'
      location: '/vendor/lodash-amd/modern'
    }, {
      name: 'sinon'
      location: '/vendor/sinon/lib/sinon'
    }
  ]
  paths:
    'chai'         : '/vendor/chai/chai'
    'sinon-chai'   : '/vendor/sinon-chai/lib/sinon-chai'
    'jquery'       : '/vendor/jquery/dist/jquery'
    'plasticine'   : '/app/plasticine'
    'crossroads'   : '/vendor/crossroads.js/dist/crossroads'
    'signals'      : '/vendor/crossroads.js/dev/lib/signals'
    'sinonBuild'   : '/vendor/sinon/pkg/sinon'

files = [
  'sinonBuild'
  'chai'
  'sinon-chai'
]


require ['jquery'], ($) ->
  $.getJSON('/list.json').done (main_node) ->
    get_files = (path, node) ->
      out = []
      new_path = path + node.name + '/'
      out.push new_path + file for file in node.files
      for directory in node.directories
        out = out.concat get_files(new_path, directory)
      return out
    files = files.concat get_files '/test/', main_node

    capitalize = (s) ->
      s.charAt(0).toUpperCase() + s[1...]

    get_requires = (path, node, is_base = false) ->
      new_path = path + node.name + '/'
      name = if is_base then "" else capitalize node.name
      describe name, ->
        for file in node.files
          require(new_path + file)()
        for directory in node.directories
          get_requires(new_path, directory)


    require files, (sinon) ->
      chai = require("chai")
      sinonChai = require("sinon-chai")

      should = chai.should()

      chai.use(sinonChai);
      mocha.setup
        globals: ['should', ]

      describe '', ->
        before (done) ->
          @sinon = sinon
          xhr = @sinon.useFakeXMLHttpRequest()
          require ['plasticine'], (plasticine) =>
            xhr.onCreate = (request) =>
              request.respondHelper = (status, data) ->
                request.respond(
                  status
                  {"Content-Type": "application/json"}
                  JSON.stringify data)
              @requests.push(request)
            @plasticine = plasticine
            done()

        beforeEach ->
          @requests = []

        get_requires('/test/', main_node, true)

      mocha.run()
