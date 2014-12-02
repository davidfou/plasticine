module.exports = -> describe 'Default behavior', ->
  it 'should expose an API', ->
    @plasticine.should.to.exist
    @plasticine.should.to.have.keys [
      'fakeRequests'
      'realRequests'
      'pendingRequests'
      'addMock'
      'restore'
      'logger'
    ]


  it 'should not intercept request', (done) ->
    params =
      headers:
        version: 'v0'
      processData: false
    $.ajax("/index.html", params).done (data) =>
      data.should.equal "<html></html>"
      @requests[0].requestHeaders.should.contain.keys 'version'
      @requests[0].requestHeaders.version.should.equal 'v0'
      @requests[0].status.should.equal 200
      done()
    @requests.should.have.length 1
    @requests[0].url.should.equal "#{window.location.origin}/index.html"
    @requests[0].respond null, 200, "<html></html>"


  it 'should not intercept request to an other domain', (done) ->
    params =
      headers:
        version: 'v0'
      processData: false
    $.ajax("http://my.other.domain.com/index.html", params).done (data) =>
      data.should.equal "<html></html>"
      @requests[0].requestHeaders.should.contain.keys 'version'
      @requests[0].requestHeaders.version.should.equal 'v0'
      @requests[0].status.should.equal 200
      done()
    @requests.should.have.length 1
    @requests[0].url.should.equal "http://my.other.domain.com/index.html"
    @requests[0].respond null, 200, "<html></html>"
