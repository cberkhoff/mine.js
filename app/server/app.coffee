# Server-side Code
rlog = (err, data) -> 
  if err
    console.log('error! '+err)
  else
    console.log('data '+data)

#defaults
v = 40
pos = {x: 100, y: 100}

if R.hexists 'pos', 'x'

R.hgetall 'pos', (err, d) -> 
  if d
    pos.x = (Number) d.x
    pos.y = (Number) d.y
  else
    console.log 'defining pos for the first time'
    R.hmset "pos", pos

exports.actions =    

  #authenticate: (params, cb) ->
    #@session.authenticate 'custom_auth', params, (r)

  testMessage: (user_id) ->
  	SS.publish.user(user_id, 'newMessage', 'mensaje penesaurio')

  broadcastMove: (kc, cb) ->
    switch kc
      when 37 then pos.x -= v
      when 38 then pos.y -= v
      when 39 then pos.x += v
      when 40 then pos.y += v
    R.hmset 'pos', pos
    SS.publish.broadcast('updatePosition', pos)