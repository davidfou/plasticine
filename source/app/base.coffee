files = [
  "crossroads"
  "lodash/functions/defer"
  "lodash/functions/delay"
]

define files, ->
  class MockBase

    crossroads = require "crossroads"
    defer      = require "lodash/functions/defer"
    delay      = require "lodash/functions/delay"

    @instanceCounts: 0
    @header:
      'X-Azendoo-Assets': 'none'

    constructor: ->
      @createdRoutes = []
      @disposed = false


    setUp: ->
      supported_method = ['get', 'put', 'post', 'delete']
      @createRoute(method) for method in supported_method when @[method]?


    createRoute: (method) ->
      @createdRoutes.push = crossroads.addRoute "/#{method.toUpperCase()}#{@route}", (xhr) =>
        xhr.filtered = false

        # TODO: should listend to onchangestate insteadof using a defer
        last_arguments = _.rest(arguments)
        defered_function = =>
          new_arguments = []

          if method in ['post', 'put']
            new_arguments.push _.clone JSON.parse(xhr.request.requestBody)
          new_arguments.push arg for arg in last_arguments

          fakeReturn = @[method].apply(@, new_arguments)

          delay (-> xhr.request.respond(
              fakeReturn.status
              MockBase.header
              JSON.stringify(fakeReturn.body))), 400

        defer defered_function


    dispose: ->
      return if @disposed
      @disposed = true
      while route.length isnt 0
        crossroads.removeRoute @createdRoutes.pop()
