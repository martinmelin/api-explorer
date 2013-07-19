COOKIE_LIFETIME = 1000 * 60 * 60 * 24 * 30 # 1 month in ms

isAuthenticated = (req) -> req.cookies.store_id and req.cookies.access_token

exports.index = (req, res) ->
  if isAuthenticated req
    res.render "app",
      store_id: req.cookies.store_id
      access_token: req.access_token
  else
    res.render "login"

exports.onLogin = (error, {res, accessToken, storeId}) ->
  return res.send(error.message, 500) if error

  res.cookie "access_token", accessToken, { maxAge: COOKIE_LIFETIME }
  res.cookie "store_id", storeId, { maxAge: COOKIE_LIFETIME }

  res.redirect "/"
