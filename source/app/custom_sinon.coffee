fakeXmlHttpRequest = require 'sinon/util/fake_xml_http_request'
core               = require 'sinon/util/core'
extend             = require 'sinon/extend'
event              = require 'sinon/util/event'
logError           = require 'sinon/log_error'

sinon = {}
for lib in [fakeXmlHttpRequest, core, extend, event, logError]
  for key, value of lib
    sinon[key] = value
console.log sinon

module.exports = sinon
