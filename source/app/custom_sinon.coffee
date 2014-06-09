root = this
previous_sinon = root.sinon
sinon =
  noConflict: ->
    root.sinon = previous_sinon
    return this
  extend: require('lodash/objects/assign')

`/* @include ../components/sinon/lib/sinon/util/event.js */`
`/* @include ../components/sinon/lib/sinon/util/fake_xml_http_request.js */`

module.exports = sinon.noConflict()
