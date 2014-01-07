require.config
  paths:
    'chai'       : '../components/chai/chai'
    'sinon-chai' : '../components/sinon-chai/lib/sinon-chai'
    'sinon'      : '../components/sinon/pkg/sinon-1.7.3'
    'plasticine'   : '../app/main'
  shim:
    'sinon':
      exports: "sinon"

files = [
  'chai'
  'sinon-chai'
  'sinon'
  'spec/plasticine'
]

require files, ->
  chai = require("chai")
  sinonChai = require("sinon-chai")
  sinon.coucou = false

  window.expect = chai.expect

  chai.use(sinonChai);
  mocha.setup
    globals: ['expect', 'sinon']

  mocha.run()
