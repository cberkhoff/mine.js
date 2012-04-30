app = require 'application'

module.exports = class MinerView extends Backbone.View

   constructor: (options = {})->
    super options
    @paper = app.paper

  render: ->
    @circle = @paper.circle 50, 40, 10
    @circle "fill", "#f00"
