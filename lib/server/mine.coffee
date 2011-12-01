class Mine
	port = 8080

	FS = require 'fs'
	HTTP = require 'http'
	PATH = require 'path'
	NODE_STATIC = require 'node-static'

	static_server = new NODE_STATIC.Server('./public')

	server = HTTP.createServer (req, res) ->
		req.addListener 'end', ->
			static_server.serve req, res

	server.listen port

	NOW = require 'now'
	everyone = NOW.initialize server

	everyone.connected ->
		everyone.now.updatePosition this.now.name, this.now.x, this.now.y
		console.log("Joined: " + this.now.name)
	everyone.disconnected ->
		everyone.now.updatePosition this.now.name, this.now.x, this.now.y
		console.log("Left: " + this.now.name)

	everyone.now.move =
		(keyCode) ->
			switch keyCode
				when 40
					this.now.y++
				when 38
					this.now.y--
				when 37
					this.now.x--
				when 39
					this.now.x++
			everyone.now.updatePosition this.now.name, this.now.x, this.now.y

module.exports = Mine