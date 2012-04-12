express = require 'express'
assets = require 'connect-assets'
eco = require 'eco'

app = express.createServer()

app.set "views", "#{__dirname}/views"
app.register ".eco", eco
app.use express.bodyParser()
app.use assets()
app.use app.router
app.use express.static "#{__dirname}/public"


app.get '/', (req, res) ->
  res.send 'Hello!'

app.listen 3000