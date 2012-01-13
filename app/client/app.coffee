# Client-side Code
$ ->
  window.paper = Raphael "main-viewport", 640, 480
  window.circle = paper.circle 100, 100, 20
  circle.attr "fill", "#f00"
  circle.attr "stroke", "#fff"

$(document).keydown (k) ->
  ck = k.keyCode
  if ck > 36 and ck < 41
    SS.client.app.move(ck)

# Bind to socket events
SS.socket.on 'disconnect', ->
SS.socket.on 'reconnect', ->   

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  SS.events.on( 'newMessage', (m) -> alert(m))      

exports.move = (ck) ->
  SS.server.app.move(ck, (p) -> window.circle.animate({cy: p.y, cx: p.x},500))
