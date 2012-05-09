Router = require 'lib/router'

gridWidth = 9
gridHeight = 7
viewportWidth = 9
viewportHeight = 6
cellSize = 40

# looking upside down?

# x,y are points in the paper/canvas. x and y conform a vector
# i,j are 2d positions
# k is for indexes

# todo
# available actions bug
# add testing capabilities
# world has bounds (create undiggable material)
# refactor & frameworkike the actions, postactions, etc
# dig removes cell
# let cells in another file (with export namespace)
# create shape object (which is drawable) in another file
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
# Vector but inside the game
class Position
  constructor: (@i, @j) ->

  x: -> 
    @i * cellSize

  y: -> 
    @j * cellSize

  moveUp: ->
    @j--
    @

  moveDown: ->
    @j++
    @

  moveLeft: ->
    @i--
    @

  moveRight: ->
    @i++
    @

  down: ->
    new Position @i, @j+1

  straightDistance: (pos) ->
    if @i is pos.i
      Math.abs pos.j - @j
    else if @j is pos.j
      Math.abs pos.i - @i
    else
      throw new Error 'Cant measure diagonal distances'

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
  # undefined cells are just air
  # width and height considering the first air row
  constructor: (@width, @height) ->
    @bounds = new Position @width+1, @height+1
    @sky = new Position @width+1, 1
    @cells = []

  indexToPosition: (k)->
    j = Math.floor k / @width
    i = k - j * @width
    new Position i, j

  positionToIndex: (pos) ->
    pos.j * @width + pos.i

  up: (pos) ->
    @cells[@positionToIndex(pos) - @width]

  right: (pos) ->
    @cells[@positionToIndex(pos)+1]

  down: (pos) ->
    @cells[@positionToIndex(pos) + @width]

  left: (pos) ->
    @cells[@positionToIndex(pos)-1]

  near: (pos) ->
    new Directions @up(pos), @right(pos), @down(pos), @left(pos)

  set: (c) ->
    @cells[@positionToIndex(c.pos)] = c

  get: (pos) ->
    @cells[@positionToIndex(pos)]

  remove: (c) ->
    k = @positionToIndex c.pos
    unless @cells[k]
      throw new Error "Cell #{k} id empty"

    c.rect.remove()
    @cells[k] = undefined

    console.log "Digging #{k}"

  inside: (pos) ->
    if 0 < pos.i < @width
      if 0 < pos.j < @height
        true
    false

  # finds the next solid surface (an empty cell above a defined cell) down
  # from the given position.
  # The result is therefor a Position!
  surface: (pos) ->
    if @down(pos)?
      pos
    else
      @surface pos.down()

  parse: (grid) ->
    if grid.length isnt @width * (@height - 1)
      throw new Error 'Invalid grid size (input doesnt need first air row)'

    console.log "parsing #{grid.length} cells"

    # First row is only air
    init = @width
    end = grid.length + @width

    for k in [init...end]
      switch grid[k]
        when 's' then @set new SoftEarthCell @indexToPosition k
        when 'e' then @set new EarthCell @indexToPosition k
        when 'h' then @set new HardEarthCell @indexToPosition k
        when 'm' then @set new MetalCell @indexToPosition k

  draw: (paper) ->
    @cells.map (c) =>
      c.draw paper

class Miner
  constructor: (@pos, @world) ->
    # Register myself in the world
    @world.players.push @

    # simple access var
    @grid = @world.grid

    # Used to skip actions if currently performing another
    @acting = false

    @availableActions = Directions.undef()
    @updateAvailableActions()

  draw: (paper) ->
    a = @circleAttrs()
    @circle = paper.circle a.x, a.y, a.h
    @circle.attr 'fill', '#f00'

  circleAttrs: =>
    h = cellSize / 2
    v =
      h: h
      x: @pos.x() + h
      y: @pos.y() + h

  act: (dir) ->
    # ignore if: 
    # - another action is in progess
    # - no available action in that direction
    unless @acting or not @availableActions[dir]?
      @acting = true
      @availableActions[dir].do dir

  fall: (cb) =>
    unless @grid.down(@pos)?
      console.log "falling!"

      attr = @circle.attr()

      @pos = @grid.surface(@pos)
      a = @circleAttrs()

      attr.cx = a.x
      attr.cy = a.y

      @circle.animate attr, 200, 'bounce', cb()
    cb()


  postAct: =>
   @fall =>
      @acting = false
      @updateAvailableActions()
      #console.log @availableActions

  updateAvailableActions: ->
    @availableActions = Directions.undef()    
    nearCells = @grid.near @pos
    #console.log nearCells

    for dir, cell of nearCells.all()
      if cell?.diggable()
        @availableActions[dir] = @digAction cell
      else
        if dir isnt 'up'
          @availableActions[dir] = @moveAction cell

  digAction: (cell) ->
    a =
      name: 'dig'
      do: (dir) =>
        @grid.remove cell
        @postAct()

  moveAction: (cell) ->
    a =
      name: 'move'
      do: (dir) =>
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

  draw: (paper) ->
    @sky = paper.rect 0, 0, @grid.sky.x(), @grid.sky.y()
    @sky.attr 'fill', '#3090C7'

    @underground = paper.rect 0, @grid.sky.y(), @grid.bounds.x(), @grid.bounds.y()
    @underground.attr 'fill', '#391919'

    @grid.draw paper

# The application bootstrapper.
class Application
  player: undefined
  initialize: ->
    viewportBounds = new Position viewportWidth, viewportHeight

    @paper = Raphael "canvas", viewportBounds.x(), viewportBounds.y()

    @world = new World new Grid gridWidth, gridHeight
    sample_grid = [
      's', 's', 's', '_', 's', 's', 's', 's', 's'
      'e', 'e', 's', '_', 's', 'e', 'h', 'h', 's'
      'h', 'e', 'e', '_', 'e', 'e', 'e', 'h', 'e'
      'e', 'e', 'e', '_', 'e', 'e', 'e', 'e', 'e'
      'm', 'm', 'm', '_', 'e', 'm', 'm', 'e', 'e'
      'h', 'h', 'm', 'm', 'e', 'h', 'm', 'e', 'e'
    ]
    @world.grid.parse sample_grid
    @world.draw @paper

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
