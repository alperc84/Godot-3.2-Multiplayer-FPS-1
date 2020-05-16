extends BaseWeapon
class_name SMG

onready var flash = get_node("flash")
onready var flash_timer = get_node("flash/timer")

func _ready():
	var _flash_timeout = flash_timer.connect("timeout", self, "_on_flash_timeout")

puppet func fire():
	get_node("sounds/fire").play()
	flash.visible = true
#	randomize()
#	flash.get_node("mesh").rotation.z = rand_range(-TAU, TAU)
	flash_timer.start()

func _on_flash_timeout():
	flash.visible = false

func is_smg():
	return true
