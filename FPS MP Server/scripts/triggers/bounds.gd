extends Area

# Level bounds that kills the player and respawns props

func _ready():
	var _body_exited = connect("body_exited", self, "_on_body_exited")

func _on_body_exited(body):
	if body is Prop:
		body.global_transform.origin = body.start_pos
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
	elif body is BasePlayer:
		body.die()
	else:
		body.queue_free()
