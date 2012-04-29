express = require 'express'
assets = require 'connect-assets'

app = express.createServer()

app.configure ->
	app.set "views", "#{__dirname}/views"
	app.use express.bodyParser()
	app.use assets()
	app.use express.static "#{__dirname}/public"


app.get '/', (req, res) ->
  res.send 'Hello!'

app.listen 3000