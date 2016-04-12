require 'lib/view_helper'
app = require 'application'

module.exports = class CanvasView extends Backbone.View

  constructor: (options = {})->
    super options
    @paper = app.paper