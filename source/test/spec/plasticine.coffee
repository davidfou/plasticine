module.exports = -> describe 'Default behavior', ->
  content =
    message  : 'Hello'
    receiver : 'world'

  it 'should define global variable', ->
    @plasticine.should.to.exist
    @plasticine.should.to.have.keys [
      'passedRequests'
      'fakeRequests'
      'pendingRequests'
      'server'
      'addMock'
      'restore'
    ]


  it 'should instantiate a fake sinon server', ->
    @plasticine.server.should.to.exist

  it 'should not intercept request', (done) ->
    $.ajax("info.json").done => done()
    @requests.should.have.length 1
    @requests[0].respondHelper 200, content
