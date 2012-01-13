# Server-side Code
pos = {x: 100, y: 100}
v = 40

exports.actions =    

  testMessage: (user_id) ->
  	SS.publish.user(user_id, 'newMessage', 'mensaje penesaurio')

  broadcastMove: (kc, cb) ->
    switch kc
      when 37 then pos.x -= v
      when 38 then pos.y -= v
      when 39 then pos.x += v
      when 40 then pos.y += v
    SS.publish.broadcast('updatePosition', pos)