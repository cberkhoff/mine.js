process.addListener 'uncaughtException', (err, stack) ->
  console.log '------------------------'
  console.log 'Exception: ' + err
  console.log err.stack
  console.log '------------------------'

new require('./lib/server/mine')