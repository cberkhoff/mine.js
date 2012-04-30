express = require 'express'
assets = require 'connect-assets'
oauth = require 'oauth'
io = require 'socket.io'

app = express.createServer()
io = io.listen app

twitterConsumerKey = '2X8ndE6rT4jNWqJUTyB9Q'
twitterConsumerSecret = '7XVntonR8JwHpYqWZA5EmXmc4h3o5uJgB1SzQ064xA'
# consumer = ->
# 	new oauth.oauth
# 		'https://twitter.com/oauth/request_token'
# 		'https://twitter.com/oauth/access_token'

app.configure ->
  app.use express.cookieParser()
  app.use express.session { secret: 'trolebus' }
  app.set "views", "#{__dirname}/views"
  app.use express.bodyParser()
  app.use assets()
  app.use express.static "#{__dirname}/public"

app.configure 'production', ->
  # https://devcenter.heroku.com/articles/using-socket-io-with-node-js-on-heroku
  io.set "transports", ["xhr-polling"]
  io.set "polling duration", 10 


app.dynamicHelpers
	session: (req, res) ->
		req.session

app.get '/', (req, res) ->
  res.send 'Hello!'

io.sockets.on 'connection', (socket) ->
  socket.on 'set nickname', (name) ->
    socket.set 'nickname', name, ->
      socket.emit 'ready'
  socket.on 'msg', ->
    socket.get 'nickname', (err, name) ->
      console.log "Name #{name}"

app.listen process.env.PORT or 3000