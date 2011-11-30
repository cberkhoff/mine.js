$(document).ready ->
	now.name = prompt "What's your name?", "" 
	now.x = 0
	now.y = 0

	now.updatePosition = (name, x, y) -> 
		$("#messages").append("<br>" + name + "x= " + x + ", y= "+ y)

$(document).keydown (k) ->
	now.move k.keyCode