sinon = require './custom_sinon'

module.exports =
  isUnset: (request) ->
    request.readyState is sinon.FakeXMLHttpRequest.UNSET
  isOpened: (request) ->
    request.readyState is sinon.FakeXMLHttpRequest.OPENED
  isHeadersReceived: (request) ->
    request.readyState is sinon.FakeXMLHttpRequest.HEADERS_RECEIVED
  isLoading: (request) ->
    request.readyState is sinon.FakeXMLHttpRequest.LOADING
  isDone: (request) ->
    request.readyState is sinon.FakeXMLHttpRequest.DONE
