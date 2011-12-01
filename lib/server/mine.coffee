fs         = require 'fs'
http       = require 'http'
path       = require 'path'
nodeStatic = require 'node-static'
now        = require 'now'

class Mine
	constructor: ->
		port    = 8080
		@server = @createServer()
		@server.listen port

	createServer: ->
		server = http.createServer (req, res) ->
			req.addListener 'end', ->
				staticServer = new nodeStatic.Server('./public')
				staticServer.serve req, res

		server

	init: ->
		everyone = now.initialize @server

		everyone.connected 		-> @now.updatePosition @now.name, @now.x, @now.y
		everyone.disconnected -> @now.updatePosition @now.name, @now.x, @now.y

		everyone.now.move = (keyCode) ->
			switch keyCode
				when 37 then @now.x--
				when 38 then @now.y--
				when 39 then @now.x++
				when 40 then @now.y++
			@now.updatePosition @now.name, @now.x, @now.y

module.exports = Mine