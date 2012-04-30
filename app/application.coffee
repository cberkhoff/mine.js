Router = require 'lib/router'
Miner = require 'views/miner'

# The application bootstrapper.
class Application
  initialize: ->
    @paper = Raphael "canvas", 640, 480

    # Ideally, initialized classes should be kept in controllers & mediator.
    # If you're making big webapp, here's more sophisticated skeleton
    # https://github.com/paulmillr/brunch-with-chaplin

    @players = []

    # Instantiate the router
    @router = new Router()
    # Freeze the object
    Object.freeze? this

  newPlayer: (name) ->
    m = new Miner @paper
    @players.push m
    m.render()


app = new Application

module.exports = app
