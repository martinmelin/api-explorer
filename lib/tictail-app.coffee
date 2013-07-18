request = require "request"
querystring = require "querystring"

class TictailApp
  @AUTH_URL: "https://tictailhq.com/oauth/authorize"
  @TOKEN_URL: "https://tictailhq.com/oauth/token"

  constructor: (options) ->
    @app = options.expressApp
    @clientId = options.clientId
    @clientSecret = options.clientSecret
    @onLogin = options.onLogin

  setupRoutes: (options = {}) ->
    login = options.login or "/login"
    authorized = options.authorized or "/authorized"

    @app.get login, @loginRoute.bind(this)
    @app.get authorized, @authorizedRoute.bind(this)

    this

  loginRoute: (req, res) ->
    qs = querystring.stringify
      response_type: "code"
      client_id: @clientId
      scope: "store.manage"

    res.redirect "#{TictailApp.AUTH_URL}?#{qs}"

  authorizedRoute: (req, res) ->
    request.post {
      url: TictailApp.TOKEN_URL
      form: {
        client_id: @clientId
        client_secret: @clientSecret
        grant_type: "authorization_code"
        code: req.param "code"
      }
    }, (error, response, body) =>
      return @onLogin(error) if error

      try
        json = JSON.parse body
      catch e
        return @onLogin \
          new Error("Failed to parse access token response as JSON")

      @onLogin null,
        req: req
        res: res
        accessToken: json.access_token
        storeId: json.store?.id

module.exports = TictailApp