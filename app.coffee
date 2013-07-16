
###
Module dependencies.
###
express = require "express"
http = require "http"
path = require "path"

routes =
  index: require "./routes"
  app: require "./routes/app"

app = express()

# All environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "ejs"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))
app.use require("connect-assets")()

# Development only
if app.get("env") is "development"
  app.use express.errorHandler()

app.get "/", routes.index
app.get "/app", routes.app.index

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
