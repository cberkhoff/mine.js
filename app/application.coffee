Router = require 'lib/router'

gridWidth = 5
gridHeight = 6
viewportWidth = 9
viewportHeight = 7
cellSize = 40

# x,y son para el dibujo
# i,j son posiciones 2d
# k es un indice

class Position
  # The position in the grid
  constructor: (@i, @j) ->
  x: -> @i * cellSize
  y: -> @j * cellSize

class Cell
  constructor: (@pos, @paper) ->
  draw: ->
    @rect = @paper.rect @pos.x(), @pos.y(), cellSize, cellSize

class AirCell extends Cell
  draw: ->
    super()
    @rect.attr 'fill', '#C0E5E4'

class SoftEarthCell extends Cell
  draw: ->
    super()
    @rect.attr 'fill', '#B99B64'

class EarthCell extends Cell
  draw: ->
    super()
    @rect.attr 'fill', '#9B8569'

class HardEarthCell extends Cell
  draw: ->
    super()
    @rect.attr 'fill', '#786B66'

class MetalCell extends Cell
  draw: ->
    super()
    @rect.attr 'fill', '#784F5F'

class Grid
  constructor: (@width, @height, @paper) ->
    @bounds = new Position @width, @height
    @cells = []

  indexToPosition: (k)->
    j = Math.floor k / @width
    i = k - j * @width
    new Position i, j

  positionToIndex: (pos) ->
    pos.j * @width + pos.i

  setCell: (c) ->
    @cells[@positionToIndex c.pos] = c

  parse: (grid) ->
    for k in [0...grid.length]
      switch grid[k]
        when 'a' then @setCell new AirCell @indexToPosition k, @paper
        when 's' then @setCell new SoftEarthCell @indexToPosition k, @paper
        when 'e' then @setCell new EarthCell @indexToPosition k, @paper
        when 'h' then @setCell new HardEarthCell @indexToPosition k, @paper
        when 'm' then @setCell new MetalCell @indexToPosition k, @paper

  draw: ->
    @cells.map (c) ->
      c.draw


class Miner
  constructor: (@pos, @paper) ->
    @draw()

  draw: ->
    h = cellSize / 2
    @circle = @paper.circle @pos.x() - h, @pos.y() - h, h
    @circle.attr "fill", "#f00"

  drawMove: (dir) ->
    attr = @circle.attr()
    switch dir
      when 'up' then attr.cy -= cellSize
      when 'down' then attr.cy += cellSize
      when 'left' then attr.cx -= cellSize
      when 'right' then attr.cx += cellSize
    @circle.animate attr, 200

  handleKeydown: (kc) ->
    switch kc
      when 38 then @drawMove 'up'
      when 40 then @drawMove 'down'
      when 37 then @drawMove 'left'
      when 39 then @drawMove 'right'

# The application bootstrapper.
class Application
  player: undefined
  initialize: ->
    viewportBounds = new Position viewportWidth, viewportHeight

    @paper = Raphael "canvas", viewportBounds.x(), viewportBounds.y()

    grid = new Grid gridWidth, gridHeight, @paper
    sample_grid = [
      'a', 'a', 'a', 'a', 'a'
      's', 's', 's', 's', 's'
      'e', 'e', 's', 'h', 's'
      'h', 'e', 'e', 'h', 'e'
      'e', 'e', 'e', 'e', 'e'
      'm', 'm', 'm', 'e', 'e'
    ]
    grid.parse sample_grid
    console.log grid.cells
    grid.draw()
    # hacer esto con un mapa que se note
    #@paper.setViewBox 0, 0, viewportBounds.x(), viewportBounds.y(), true

    # Ideally, initialized classes should be kept in controllers & mediator.
    # If you're making big webapp, here's more sophisticated skeleton
    # https://github.com/paulmillr/brunch-with-chaplin

    # Instantiate the router
    #@router = new Router()
    @joinGame()

  joinGame: ->
    @player = new Miner(new Position(3, 2), @paper)
    $(document).keydown (kde) =>
      @player.handleKeydown kde.keyCode

app = new Application

module.exports = app
