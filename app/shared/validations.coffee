exports.username = (u) ->
  ul = u.length
  return {success: false, message: "Username is too short"} if ul < 4
  return {success: false, message: "Username is too long"} if ul > 10
  {success: true}

exports.password = (p) ->
  pl = p.length
  return {success: false, message: "Password is too short"} if pl < 4
  return {success: false, message: "Password is too long"} if pl > 10
  {success: true}