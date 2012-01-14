exports.authenticate = (params, cb) ->
  credStatus = SS.shared.validations.username params.username
  if credStatus.success
    R.get 'user:' + params.username,  (err, d) ->
      if d
        db_user = JSON.parse d
        if db_user.password == params.password
          cb {success: true, user_id: params.username, message: "ok"}
        else
          cb {success: false, message: "password mismatch"}
      else
        R.set 'user:' + params.username, JSON.stringify {username: params.username, password: params.password}
        cb {success: true, message: "new user", user_id: params.username}
  else
    cb credStatus
