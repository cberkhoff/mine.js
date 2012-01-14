# Server-side Code
rlog = (err, data) -> 
  if err
    console.log('error! '+err)
  else
    console.log('data '+data)

#defaults
v = 40
pos = {x: 100, y: 100}

R.get 'pos', (err, d) -> 
  if d
    pos = JSON.parse(d)
  else
    console.log 'defining pos for the first time'
    R.set "pos", JSON.stringify pos

exports.actions =    

  authenticate: (params, cb) ->
    @session.authenticate 'custom_auth', params, (r)

  testMessage: (user_id) ->
  	SS.publish.user(user_id, 'newMessage', 'mensaje penesaurio')

  broadcastMove: (kc, cb) ->
    switch kc
      when 37 then pos.x -= v
      when 38 then pos.y -= v
      when 39 then pos.x += v
      when 40 then pos.y += v
    R.set 'pos', JSON.stringify pos
    SS.publish.broadcast('updatePosition', pos)