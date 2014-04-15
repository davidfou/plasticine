crossroads = require 'crossroads'
sinon      = require 'custom-sinon'
MockBase   = require '../app/base'

module.exports = Plasticine =
  passedRequests  : []
  fakeRequests    : []
  pendingRequests : []

# setup crossroads
crossroads.normalizeFn = crossroads.NORM_AS_OBJECT;
crossroads.ignoreState = true

initialize = ->
  # instantiate and configure fake server
  Plasticine.server = sinon.useFakeXMLHttpRequest()
  Plasticine.server.useFilters = true
  Plasticine.server.onCreate = (request) ->
    Plasticine.pendingRequests.push {request: request, filtered: true}
  Plasticine.server.addFilter (method, url) ->
    xhr = Plasticine.pendingRequests.pop()
    url = '/' + url unless url.charAt(0) is '/'
    crossroads.parse "/#{method}#{url.split('?')[0]}", [xhr]
    array_to_add = if xhr.filtered then 'passedRequests' else 'fakeRequests'
    Plasticine[array_to_add].push xhr
    return xhr.filtered
initialize()

# public API

Plasticine.addMock = (params = {}) ->
  model = new MockBase()
  model[key] = params[key] for key in ['route', 'get', 'put', 'post', 'patch', 'delete']
  model.setUp()

  return model

Plasticine.restore = ->
  Plasticine.server.restore()
  Plasticine.server.filters = []
  initialize()
