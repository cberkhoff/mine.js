express = require 'express'

app = express.createServer express.logger()

app.use express.static "#{__dirname}/public"

app.get '/', (req, res) ->
    res.render 'index.html'

port = process.env.PORT or 3000
app.listen port, ->
  console.log "Listening on #{port}"