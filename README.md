# Plasticine

Play as much as you want with me and get a nice server.

## About

Plasticine is designed by a font-end developper for front-end developpers. It supplies a simple API to fake some requests. It can be used when dvelopping a new feature without a ready back-end. Just define the API the server will use, create your mock and start to develop!

## Usage

The library is define as UMD module (see [amdWeb](https://github.com/umdjs/umd/blob/master/amdWeb.js)). It can be injected as an AMD module or added in the JavascriptCode and define the global variable `Plasticine`.

Here an example to play with Plasticine:

    Plasticine.addMock({
      route: '/info.json',
      get: function() {
        return {status: 200, body: {message: 'Hello world!'}};
      }
    });
    
With this sample, any request GET on route info.json is faked (no request is send). The response of the request is defined by the `get` callback.

### `Plasticine.addMock(params):Mock`

`params` is an object with those keys:

* `route`: define the request route to catch. It can have parameters, syntax define by [crossroads.js](http://millermedeiros.github.io/crossroads.js/#crossroads-add_route). This parameter is mandatory.
* `get`: callback to determine a GET request. Callback get route variables as parameters:
* 
      Plasticine.addMock({
        route: '/messages/{id}.json',
        get: function(route_params) {
          if (route_params.id === '1')
            return {status: 200, body: {message: 'Hello world!'}};
          else
            return {status: 404, body: {error: 'unknown message'}};
        }
      });
* `delete`: same as `get` but on a DELETE request.
* `post`: same as `get` but on a POST request and callback second parameter has request payload:
* 
      Plasticine.addMock({
        route: '/messages/{id}.json',
        post: function(route_params, data) {
          data.id = Math.round(Math.random()*1000000000)
          return {status: 200, body: data};
        }
      });
* `put`: same as `post` but on a PUT request.

### `Mock.dispose()`

Calling this method makes the `Mock` return by `Plasticine.addMock()` not to intercept requests anymore.

## Dependencies

All dependencies are include in the library:

* Library dependencies
  * [Almond](https://github.com/jrburke/almond): to load library modules
  * [Crossroads.js](http://millermedeiros.github.io/crossroads.js): to define route and parse request url
  * [Lodash](http://lodash.com/): AMD utilities
  * [Sinon.js](http://sinonjs.org/): to intercept requests and to test the library
* Development dependencies
  * [Chai](http://chaijs.com/): assertion library 
  * [jQuery](http://jquery.com/): to send requests
  * [Mocha](http://visionmedia.github.io/mocha/): test framework
  * [Sinon.js](http://sinonjs.org/): to create fake server

## Roadmap

* Configure custom delay
* Change server response
* Chrome extention to mixed up faked and not faked requests