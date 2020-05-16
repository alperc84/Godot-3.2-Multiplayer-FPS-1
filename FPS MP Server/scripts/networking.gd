extends Node

var tick : float = 20.0
var tick_timer : float = 0.0
var can_send : bool = false

func _physics_process(delta):
	var _t = OS.get_ticks_msec() * 0.001
	tick_timer += delta
	if tick_timer < 1.0 / tick:
		can_send = false
	else:
		tick_timer -= 1.0 / tick
		# Send stuff
		can_send = true
	
	if can_send:
		pass
