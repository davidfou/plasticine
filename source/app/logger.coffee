Signal = require 'signals'

module.exports =
  debug : new Signal()
  warn  : new Signal()
  error : new Signal()
