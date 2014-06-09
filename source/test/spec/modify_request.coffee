clone = require 'lodash/objects/clone'
module.exports = -> describe 'Modify request', ->

  done_callback = null
  fail_callback = null
  ajax_call     = null
  content       = null

  before ->
    ajax_call = ->
      $.ajax
        type : 'GET'
        url  : '/info.json'
      .done(done_callback)
      .fail(fail_callback)

  beforeEach ->
    mock_callback = sinon.spy()
    done_callback = sinon.spy()
    fail_callback = sinon.spy()

    content =
      message  : 'Hello'
      receiver : 'world'

  describe 'basic functionalities', ->
    mock          = null
    mock_callback = null

    before ->
      mock = @plasticine.addMock
        route: '/info.json'
        afterGet: (request) ->
          copy = clone request, true
          mock_callback(copy)
          request.body.emitter = 'Main server'

    after ->
      mock.dispose()

    beforeEach ->
      mock_callback = sinon.spy()

    it 'should not intercept request and modify the response', (done) ->
      ajax_call().always =>
        fail_callback.should.not.have.been.called
        done_callback.should.have.been.calledOnce
        mock_callback.should.have.been.calledOnce
        mock_callback.firstCall.should.have.been.calledWith
          status  : 200
          headers : {}
          body    :
            message  : 'Hello'
            receiver : 'world'
        JSON.parse(done_callback.firstCall.args[0]).should.deep.equal
          message  : 'Hello'
          receiver : 'world'
          emitter  : 'Main server'
        done()
      @requests.should.have.length 1
      @requests[0].respondHelper 200, content

  describe 'with concurrent mocks', ->
    mock1          = null
    mock2          = null
    mock_callback1 = null
    mock_callback2 = null

    before ->
      mock1 = @plasticine.addMock
        route: '/info.json'
        afterGet: (request) ->
          mock_callback1(clone request, true)
          request.body.emitter = 'Main server'

      mock2 = @plasticine.addMock
        route: '/info.json'
        afterGet: (request) ->
          mock_callback2(clone request, true)
          request.body.message = 'Ciao'

    after ->
      mock1.dispose()
      mock2.dispose()

    beforeEach ->
      mock_callback1 = sinon.spy()
      mock_callback2 = sinon.spy()

    it 'should apply mock consecutively', (done) ->
      ajax_call().always =>
        fail_callback.should.not.have.been.called
        done_callback.should.have.been.calledOnce
        mock_callback1.should.have.been.calledOnce
        mock_callback2.should.have.been.calledOnce
        mock_callback1.should.have.been.calledBefore mock_callback2
        mock_callback1.should.have.been.calledWith
          status  : 200
          headers : {}
          body    :
            message  : 'Hello'
            receiver : 'world'
        mock_callback2.should.have.been.calledWith
          status  : 200
          headers : {}
          body    :
            message  : 'Hello'
            receiver : 'world'
            emitter  : 'Main server'
        JSON.parse(done_callback.firstCall.args[0]).should.deep.equal
          message  : 'Ciao'
          receiver : 'world'
          emitter  : 'Main server'
        done()
      @requests.should.have.length 1
      @requests[0].respondHelper 200, content
