FS = require 'fs'

HTTP = require 'http'

server = HTTP.createServer (req, res) ->
	FS.readFile 'client.html', (err, data) ->
		res.writeHead 200, {'Content-Type':'text/html'}
		res.write data
		res.end()

server.listen 8080

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
