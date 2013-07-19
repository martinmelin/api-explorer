express = require "express"
http = require "http"
path = require "path"
livereload = require "express-livereload"

TictailApp = require "./lib/tictail-app"

try
  client = require "./secrets/client"
catch e
  console.log "Missing client credentials. Insert them into " +
              "client.sample.coffee and rename the file to client.coffee."
  process.exit()

routes = require "./routes"

app = express()

livereload app,
  watchDir: path.join(__dirname, "assets")
  exts: ["less", "coffee"]

tictailApp = new TictailApp(
  expressApp: app
  clientId: client.ID
  clientSecret: client.SECRET
  onLogin: routes.onLogin
)

# All environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "ejs"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "assets"))
app.use require("connect-assets")()

# Development only
if app.get("env") is "development"
  app.use express.errorHandler()

tictailApp.setupRoutes()
app.get "/", routes.index
app.get "/logout", routes.logout

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
