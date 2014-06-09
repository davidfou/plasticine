Router        = require "crossroads"
Logger        = require "./logger"
requestStatus = require "./request_status"

clone      = require "lodash/objects/clone"
isEmpty    = require "lodash/objects/isEmpty"
# capitalize should be in lodah soon
# capitalize = require "lodash/strings/capitalize"
capitalize = (s) -> s[0].toUpperCase() + s[1..]

defineRouterCallback = (method, callback) ->
  route = "/#{method.toUpperCase()}#{@route}"
  @createdRoutes.push Router.addRoute route, callback

fakeRequest = (method) ->
  defineRouterCallback.call this,  method, (xhr, route_params) =>
    if xhr.fakeResponse?
      Logger.warn.dispatch "ALREADY_FAKED", this, xhr
      return false

    xhr.fakeResponse =
      mock          : this
      isResponseSet : false
      response      : null

    ready_state_change = =>
      return unless requestStatus.isOpened(xhr.request) and xhr.request.sendFlag
      return if xhr.fakeResponse.isResponseSet
      xhr.fakeResponse.isResponseSet = true

      new_arguments = [route_params]
      if method in ['post', 'put', 'patch']
        new_arguments.push JSON.parse(xhr.request.requestBody)

      xhr.fakeResponse.response = @[method].apply(@, new_arguments)
      xhr.fakeResponse.response.headers = MockBase.header
      xhr.response = clone xhr.fakeResponse.response, true
      xhr.responseReady.dispatch()

    xhr.request.addEventListener "readystatechange", ready_state_change, false

modifyRequest = (method) ->
  defineRouterCallback.call this,  method, (xhr, route_params) =>
    xhr.responseReady.add =>
      new_response = xhr.response
      modifier =
        source : clone(xhr.response, true)
        output : new_response
      @["after#{capitalize(method)}"](new_response)

      xhr.responseModifiers = modifier
      xhr.response = clone modifier.output, true


module.exports = class MockBase
  @header: {}

  constructor: ->
    @createdRoutes = []
    @disposed = false


  setUp: ->
    supported_method = ['get', 'put', 'post', 'delete', 'patch']
    for method in supported_method when @[method]?
      fakeRequest.call(this, method)

    for method in supported_method when @["after#{capitalize(method)}"]?
      modifyRequest.call(this, method)


  dispose: ->
    return if @disposed
    @disposed = true
    while @createdRoutes.length isnt 0
      Router.removeRoute @createdRoutes.pop()
