require.config
  baseUrl: '/app'
  packages: [
    {
      name: 'lodash'
      location: '/components/lodash-amd/modern'
    }
    {
      name: 'sinon'
      location: '/components/sinon/lib/sinon'
      main: '../sinon'
    }
  ]
  paths:
    'chai'         : '/components/chai/chai'
    'sinon-chai'   : '/components/sinon-chai/lib/sinon-chai'
    'jquery'       : '/components/jquery/dist/jquery'
    'plasticine'   : '/app/plasticine'
    'crossroads'   : '/components/crossroads.js/dist/crossroads'
    'signals'      : '/components/crossroads.js/dev/lib/signals'
  shim:
    'sinon':
      deps: [
        '/components/sinon/lib/sinon.js'
        '/components/sinon/lib/sinon/util/event.js'
        '/components/sinon/lib/sinon/util/fake_xml_http_request.js'
      ]
      exports: 'sinon'

files = [
  'chai'
  'sinon-chai'
  'sinon'
]


require ['jquery'], ($) ->
  $.ajax({url: 'spec/list.json', method: 'GET'}).done (data) ->
    main_node = JSON.parse(data)
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


    require files, ->
      chai = require("chai")
      sinonChai = require("sinon-chai")

      should = chai.should()

      chai.use(sinonChai);
      mocha.setup
        globals: ['should', 'sinon']

      describe '', ->
        before (done) ->
          require ['sinon/util/event', 'sinon/util/fake_xml_http_request'], =>
            xhr = sinon.useFakeXMLHttpRequest()
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
