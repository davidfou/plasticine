crossroads = require "crossroads"
clone      = require "lodash/objects/clone"

module.exports = class MockBase

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
    route = "/#{method.toUpperCase()}#{@route}"
    @createdRoutes.push crossroads.addRoute route, (xhr, route_params) =>
      xhr.filtered    = false
      xhr.responseSet = false

      respond_callback = (e) =>
        return unless xhr.request.readyState is 1 and xhr.request.sendFlag and not xhr.responseSet
        xhr.responseSet = true

        new_arguments = [route_params]
        if method in ['post', 'put']
          new_arguments.push JSON.parse(xhr.request.requestBody)

        fakeReturn = @[method].apply(@, new_arguments)

        xhr.request.respond(
          fakeReturn.status
          MockBase.header
          JSON.stringify(fakeReturn.body))

      xhr.request.addEventListener "readystatechange", respond_callback, false


  dispose: ->
    return if @disposed
    @disposed = true
    while @createdRoutes.length isnt 0
      crossroads.removeRoute @createdRoutes.pop()
