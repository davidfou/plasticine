describe 'default behavior', ->

  Plasticine = null
  before (done) ->
    require ['plasticine'], (plasticine) ->
      Plasticine = plasticine
      done()


  it 'should define global variable', ->
    expect(Plasticine).to.exist
    expect(Plasticine).to.have.keys [
      'passedRequests'
      'fakeRequests'
      'pendingRequests'
      'server'
      'addMock'
    ]


  it 'should instantiate a fake sinon server', ->
    expect(Plasticine.server).to.exist


  it 'should not intercept', ->
    expect(true).to.be.ok
