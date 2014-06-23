Router        = require 'crossroads'
Signal        = require 'signals'
Mock          = require './mock'
Logger        = require './logger'
requestStatus = require './request_status'

sinon = require './custom_sinon'
defer = require "lodash/functions/defer"

# setup Router
Router.normalizeFn = Router.NORM_AS_OBJECT;
Router.ignoreState = true
Router.greedy = true

initialize = ->
  protect_from_faking = false
  protectFromFaking = ->
    protect_from_faking = true

  getProtectFromFakingValue = ->
    out = protect_from_faking
    protect_from_faking = false
    return out

  # instantiate and configure fake request
  Request = sinon.useFakeXMLHttpRequest()

  Request.useFilters = true

  Request.onCreate = (request) ->
    Plasticine.pendingRequests.push
      request           : request
      protectFromFaking : getProtectFromFakingValue()
      responseReady     : new Signal()
      fakeResponse      : null
      responseModifiers : []
      processBody: ->
        unless @isBodyProcessed
          @isBodyProcessed = true
          @response.body = JSON.parse @response.body
      isBodyProcessed   : false

  Request.addFilter (method, url) ->
    xhr = Plasticine.pendingRequests.pop()
    if xhr.protectFromFaking
      Plasticine.realRequests.push xhr
      return true
    else
      url = '/' + url unless url.charAt(0) is '/'
      Router.parse "/#{method}#{url.split('?')[0]}", [xhr]
      Plasticine.fakeRequests.push xhr

      xhr.responseReady.add ->
        xhr.response.body = JSON.stringify(xhr.response.body) if xhr.isBodyProcessed
        xhr.request.respond(
          xhr.response.status
          xhr.response.headers
          xhr.response.body)

      unless xhr.fakeResponse?
        protectFromFaking()
        real_request = new Request
        xhr.realResponse =
          request : real_request

        real_request.open method, url, true
        xhr.request.onSend = ->
          for key, value of xhr.request.requestHeaders
            real_request.setRequestHeader key, value
          real_request.send xhr.request.requestBody || ''

        ready_state_change = ->
          if requestStatus.isDone(real_request)
            xhr.response =
              status  : real_request.status
              headers : real_request.requestHeaders
              body    : real_request.responseText
            xhr.responseReady.dispatch()
        real_request.addEventListener "readystatechange", ready_state_change, false
        ready_state_change()

      return false

initialize()

# public API

module.exports = Plasticine =
  fakeRequests    : []
  realRequests    : []
  pendingRequests : []
  logger          : Logger

  restore: ->
    Request.restore()
    Request.filters = []
    initialize()

  addMock: (params = {}) ->
    model = new Mock()
    available_params = [
      'route'
      'get'
      'put'
      'post'
      'patch'
      'delete'
      'afterGet'
      'afterPut'
      'afterPost'
      'afterPatch'
      'afterDelete'
    ]
    model[key] = params[key] for key in available_params
    model.setUp()

    return model
