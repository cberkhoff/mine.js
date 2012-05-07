Router = require 'lib/router'

gridWidth = 9
gridHeight = 6
viewportWidth = 9
viewportHeight = 7
cellSize = 40

# looking upside down?

# x,y are points in the paper/canvas. x and y conform a vector
# i,j are 2d positions
# k is for indexes

# todo
# world has air & backgroun
# dig removes cell
# let cells in another file (with export namespace)
# create shape object (which is drawable)
#  - miner uses a circle which has different attrs as a rect

# tests
# grid: size and parse

class Directions
  constructor: (@up, @right, @down, @left) ->

  @undef: ->
    new Directions undefined, undefined, undefined, undefined

  all: ->
    {up: @up, right: @right, down: @down, left: @left}

  sides: ->
    {left: @left, right: @right}

# The position in the grid
class Position
  constructor: (@i, @j) ->

  x: -> 
    @i * cellSize

  y: -> 
    @j * cellSize

  moveUp: ->
    @j--

  moveDown: ->
    @j++

  moveLeft: ->
    @i--

  moveRight: ->
    @i++

  move: (dir) ->
    switch dir
      when 'up' then @moveUp()
      when 'down' then @moveDown()
      when 'left' then @moveLeft()
      when 'right' then @moveRight()

class Cell
  constructor: (@pos) ->

  draw: (paper) ->
    @rect = paper.rect @pos.x(), @pos.y(), cellSize, cellSize

  diggable: ->
    @toughness > 0

  toughness: 0

class AirCell extends Cell
  draw: (paper) ->
    super paper
    @rect.attr 'fill', '#3090C7'

  toughness: 0

class MineCell extends Cell
  draw: (paper) ->
    super paper
    @rect.attr 'fill', '#391919'

  toughness: 0

class SoftEarthCell extends Cell
  draw: (paper) ->
    super paper
    @rect.attr 'fill', '#B99B64'

  toughness: 2

class EarthCell extends Cell
  draw: (paper) ->
    super paper
    @rect.attr 'fill', '#9B8569'

  toughness: 3

class HardEarthCell extends Cell
  draw: (paper) ->
    super paper
    @rect.attr 'fill', '#786B66'

  toughness: 4

class MetalCell extends Cell
  draw: (paper) ->
    super paper
    @rect.attr 'fill', '#784F5F'

  toughness: 5

class Grid
  constructor: (@width, @height) ->
    @bounds = new Position @width, @height
    @cells = []

  indexToPosition: (k)->
    j = Math.floor k / @width
    i = k - j * @width
    new Position i, j

  positionToIndex: (pos) ->
    pos.j * @width + pos.i

  near: (pos) ->
    k = @positionToIndex pos
    new Directions @cells[k-@width], @cells[k+1], @cells[k+@width], @cells[k-1]

  setCell: (c) ->
    @cells[@positionToIndex c.pos] = c

  dig: (c) ->
    k = @positionToIndex c.pos
    @cells[k] = new MineCell k 

  parse: (grid) ->
    if grid.length isnt @width * @height
      new Error 'Invalid grid size'
    for k in [0...grid.length]
      switch grid[k]
        when '_' then @setCell new MineCell @indexToPosition k
        when 'a' then @setCell new AirCell @indexToPosition k
        when 's' then @setCell new SoftEarthCell @indexToPosition k
        when 'e' then @setCell new EarthCell @indexToPosition k
        when 'h' then @setCell new HardEarthCell @indexToPosition k
        when 'm' then @setCell new MetalCell @indexToPosition k

  draw: (paper) ->
    @cells.map (c) =>
      c.draw paper

class Miner
  constructor: (@pos, @world) ->
    # Register myself in the world
    @world.players.push @

    # Used to skip actions if currently performing another
    @acting = false

    @availableActions = Directions.undef()
    @updateAvailableActions()

  draw: (paper) ->
    a = @circleAttrs()
    @circle = paper.circle a.x, a.y, a.h
    @circle.attr 'fill', '#f00'

  circleAttrs: ->
    h = cellSize / 2
    v =
      h: h
      x: @pos.x() + h
      y: @pos.y() + h

  act: (dir) ->
    #ignore if another action is in progess
    unless @acting
      @acting = true
      console.log @availableActions[dir].do
      @availableActions[dir].do()

  postAct: =>
    @acting = false
    @updateAvailableActions()
    console.log @availableActions

  updateAvailableActions: ->
    nearCells = @world.grid.near @pos

    for dir, cell of nearCells.all()
      if cell?.diggable()
        @availableActions[dir] = @digAction cell
      else
        @availableActions[dir] = @moveAction cell

  digAction: (cell) ->
    a =
      name: 'dig'
      do: =>
        @world.grid.dig cell
        @postAct()

  moveAction: (cell) ->
    a =
      name: 'move'
      do: =>
        attr = @circle.attr()
        @pos.move dir
        a = @circleAttrs()

        attr.cx = a.x
        attr.cy = a.y

        @circle.animate attr, 200, '<>', @postAct
        

  handleKeydown: (kc) ->
    switch kc
      when 38 then @act 'up'
      when 40 then @act 'down'
      when 37 then @act 'left'
      when 39 then @act 'right'

class World
  constructor: (@grid) ->
    @players = []

# The application bootstrapper.
class Application
  player: undefined
  initialize: ->
    viewportBounds = new Position viewportWidth, viewportHeight

    @paper = Raphael "canvas", viewportBounds.x(), viewportBounds.y()

    @world = new World new Grid gridWidth, gridHeight
    sample_grid = [
      'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a', 'a'
      's', 's', 's', '_', 's', 's', 's', 's', 's'
      'e', 'e', 's', '_', 's', 'e', 'h', 'h', 's'
      'h', 'e', 'e', 'h', 'e', 'e', 'e', 'h', 'e'
      'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'
      'm', 'm', 'm', 'e', 'e', 'm', 'm', 'e', 'e'
      'h', 'h', 'm', 'e', 'e', 'h', 'm', 'e', 'e'
    ]
    @world.grid.parse sample_grid
    @world.grid.draw @paper

    #console.log @world.grid.cells[10]
    # hacer esto con un mapa que se note
    #@paper.setViewBox 0, 0, viewportBounds.x(), viewportBounds.y(), true

    # Ideally, initialized classes should be kept in controllers & mediator.
    # If you're making big webapp, here's more sophisticated skeleton
    # https://github.com/paulmillr/brunch-with-chaplin

    # Instantiate the router
    #@router = new Router()
    @joinGame()

  joinGame: ->
    @player = new Miner new Position(4, 0), @world
    @player.draw @paper
    $(document).keydown (kde) =>
      @player.handleKeydown kde.keyCode

app = new Application

module.exports = app
