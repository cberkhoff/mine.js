# Client-side Code
$ ->
  window.paper = Raphael "main-viewport", 640, 480
  window.circle = paper.circle 100, 100, 20
  circle.attr "fill", "#f00"
  circle.attr "stroke", "#fff"

$(document).keydown (k) ->
  kc = k.keyCode
  if kc > 36 and kc < 41
    SS.server.app.broadcastMove(kc)

# Bind to socket events
SS.socket.on 'disconnect', ->
SS.socket.on 'reconnect', ->   

# This method is called automatically when the websocket connection is established. Do not rename/delete
exports.init = ->
  SS.events.on('updatePosition', (p) -> 
    window.circle.animate({cy: p.y, cx: p.x}, 500))

exports.move = (ck) ->
  SS.server.app.move(ck, (p) -> window.circle.animate({cy: p.y, cx: p.x},500))
