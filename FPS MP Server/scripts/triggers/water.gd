extends Area

func _ready():
	var _area_entered = connect("area_entered", self, "_on_area_entered")
	var _area_exited = connect("area_exited", self, "_on_area_exited")
	var _body_entered = connect("body_entered", self, "_on_body_entered")
	var _body_exited = connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body is Prop:
		body.set_state("water", true)
	elif body is BasePlayer:
		body.set_state("water", true)
	elif body is PhysicalBone:
		body.linear_velocity = Vector2.UP

func _on_body_exited(body):
	if body is Prop:
		body.set_state("water", false)
	if body is BasePlayer:
		body.set_state("water", false)

func _on_area_entered(area):
	if area.owner is Player:
		area.owner.set_water_filter(true)

func _on_area_exited(area):
	if area.owner is Player:
		area.owner.set_water_filter(false)
