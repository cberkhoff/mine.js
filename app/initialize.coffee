application = require 'application'

$ ->
  application.initialize()

  # If history exists
  Backbone.history?.start()
