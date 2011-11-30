fs = require 'fs'

{spawn} = require 'child_process'
{print} = require 'util'

build = (callback) ->
	coffee = spawn 'coffee', ['-c', '-o', 'public/js', 'client.coffee']
	coffee = spawn 'coffee', ['-c', '-o', 'server', 'mine.coffee']
	
	coffee.stderr.on 'data', (data) ->
		process.stderr.write data.toString()
	
	coffee.stdout.on 'data', (data) ->
		print data.toString()
	
	coffee.on 'exit', (code) ->
		callback?() if code is 0

go = (callback) ->
	invoke 'build'
	spawn 'node', ['server/mine.js'] 

task 'build', 'Build the resources', ->
	build()

task 'go', 'Build the resources and executes the server', ->
	go()