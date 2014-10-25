root = this
previous_sinon = root.sinon
sinon =
  noConflict: ->
    root.sinon = previous_sinon
    return this
  extend: require "lodash/objects/assign"

`@@includeSinonEvent`
`@@includeSinonFakeXmlHttpRequest`

module.exports = sinon.noConflict()
