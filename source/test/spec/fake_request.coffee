module.exports = -> describe 'Fake request', ->

  mock_callback   = null
  done_callback   = null
  fail_callback   = null
  ajax_call       = null
  content         = null

  before ->
    ajax_call = ->
      $.ajax
        type : 'GET'
        url  : '/info.json'
      .done(done_callback)
      .fail(fail_callback)

  beforeEach ->
    mock_callback = @sinon.spy()
    done_callback = @sinon.spy()
    fail_callback = @sinon.spy()

    content =
      message  : 'Hello'
      receiver : 'world'

  describe 'basic functionalities', ->
    mock = null

    before ->
      mock = @plasticine.addMock
        route: '/info.json'
        get: ->
          mock_callback()
          status: 200
          body:
            message  : 'Someone here?'
            receiver : 'world'

    it 'should intercept with a static route on a GET', (done) ->
      ajax_call().always =>
        @requests.should.have.length 0
        fail_callback.should.not.have.been.called
        done_callback.should.have.been.calledOnce
        response_text = done_callback.firstCall.args[0]
        (JSON.parse response_text).should.be.deep.equal
          message  : 'Someone here?'
          receiver : 'world'
        mock_callback.should.have.been.calledOnce
        done()


    it 'should not intercept when the mock is disposed', (done) ->
      mock.dispose()
      ajax_call().always ->
        fail_callback.should.not.have.been.called
        done_callback.should.have.been.calledOnce
        response_text = done_callback.firstCall.args[0]
        (JSON.parse response_text).should.be.deep.equal content
        mock_callback.should.not.have.been.called
        done()
      @requests.should.have.length 1
      @requests[0].respondHelper 200, content

  describe 'arguments passed to callbacks', ->
    mock                 = null
    get_callback_stub    = null
    delete_callback_stub = null
    post_callback_stub   = null
    put_callback_stub    = null
    patch_callback_stub  = null

    before ->
      get_callback_stub    = @sinon.stub()
      delete_callback_stub = @sinon.stub()
      post_callback_stub   = @sinon.stub()
      put_callback_stub    = @sinon.stub()
      patch_callback_stub  = @sinon.stub()
      get_callback_stub.returns status: 200, body: {}
      delete_callback_stub.returns status: 200, body: {}
      post_callback_stub.returns status: 200, body: {}
      put_callback_stub.returns status: 200, body: {}
      patch_callback_stub.returns status: 200, body: {}

      mock = @plasticine.addMock
        route  : '/info.json'
        get    : get_callback_stub
        delete : delete_callback_stub
        post   : post_callback_stub
        put    : put_callback_stub
        patch  : patch_callback_stub

    after ->
      mock.dispose()

    it 'should not give argument on a GET', (done) ->
      $.ajax
        type : 'GET'
        url  : '/info.json'
      .always ->
        get_callback_stub.getCall(0).args.should.have.length 1
        done()

    it 'should not give argument on a DELETE', (done) ->
      $.ajax
        type : 'DELETE'
        url  : '/info.json'
      .always ->
        delete_callback_stub.getCall(0).args.should.have.length 1
        done()

    it 'should give request data as argument on a POST', (done) ->
      data = {message: 'Hello', author: 'world'}
      $.ajax
        type : 'POST'
        url  : '/info.json'
        data : JSON.stringify(data)
      .always ->
        post_callback_stub.getCall(0).args.should.have.length 2
        post_callback_stub.getCall(0).args[1].should.eql data
        done()

    it 'should give request data as argument on a PUT', (done) ->
      data = {message: 'Hello', author: 'world'}
      $.ajax
        type : 'PUT'
        url  : '/info.json'
        data : JSON.stringify(data)
      .always ->
        put_callback_stub.getCall(0).args.should.have.length 2
        put_callback_stub.getCall(0).args[1].should.be.eql data
        done()

    it 'should give request data as argument on a PATCH', (done) ->
      data = {message: 'Hello', author: 'world'}
      $.ajax
        type : 'PATCH'
        url  : '/info.json'
        data : JSON.stringify(data)
      .always ->
        patch_callback_stub.getCall(0).args.should.have.length 2
        patch_callback_stub.getCall(0).args[1].should.be.eql data
        done()

  describe 'with concurrent mocks', ->
    mock1      = null
    mock2      = null
    mock1_spy  = null
    mock2_spy  = null
    logger_spy = null

    before ->
      mock1_spy  = @sinon.spy()
      mock2_spy  = @sinon.spy()
      logger_spy = @sinon.spy()

      mock1 = @plasticine.addMock
        route  : '/info.json'
        get    : ->
          mock1_spy()
          status : 200
          body   : {}

      mock2 = @plasticine.addMock
        route  : '/info.json'
        get    : ->
          mock2_spy()
          status : 200
          body   : {}

    after ->
      mock1.dispose()
      mock2.dispose()

    it 'should warn if 2 mocks try to fake the same route', (done) ->
      @plasticine.logger.warn.add logger_spy
      $.ajax
        type : 'GET'
        url  : '/info.json'
      .always (data, event, xhr) ->
        mock1_spy.should.have.been.calledOnce
        mock2_spy.should.have.not.been.called
        logger_spy.should.have.been.calledOnce
        logger_spy.firstCall.args[0].should.equal 'ALREADY_FAKED'
        logger_spy.firstCall.args[1].should.equal mock2
        done()
