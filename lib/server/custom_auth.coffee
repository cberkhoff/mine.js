exports.authenticate = (username, password, cb) ->
  R.get 'user:' + username,  (err, d) ->
    if d
      
    else
      R.set 'user:' + username, {username: username, password: password}
      cb({status: "new", user_id: username})
