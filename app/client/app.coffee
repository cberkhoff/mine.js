# Client-side Code
$ ->
  window.pos = {x: 100, y: 100}
  window.v = 40
  window.paper = Raphael "main-viewport", 640, 480
  window.circle = paper.circle window.pos.x, window.pos.y, 20
  circle.attr "fill", "#f00"
  circle.attr "stroke", "#fff"

$(document).keydown (k) ->
  switch k.keyCode
    when 37 then window.circle.animate({cx: window.pos.x -= window.v }, 500)
    when 38 then window.circle.animate({cy: window.pos.y -= window.v }, 500)
    when 39 then window.circle.animate({cx: window.pos.x += window.v }, 500)
    when 40 then window.circle.animate({cy: window.pos.y += window.v }, 500)

# Bind to socket events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'reconnect', ->   $('#message').text('SocketStream server is up :-)')

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  # Make a call to the server to retrieve a message
  SS.server.app.init (response) ->
    $('#message').text(response)

  # Start the Quick Chat Demo
  SS.client.demo.init()