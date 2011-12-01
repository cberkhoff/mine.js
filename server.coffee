Mine = require './lib/server/mine'

process.addListener 'uncaughtException', (err, stack) ->
  console.log '------------------------'
  console.log 'Exception: ' + err
  console.log err.stack
  console.log '------------------------'

app = new Mine
app.init()