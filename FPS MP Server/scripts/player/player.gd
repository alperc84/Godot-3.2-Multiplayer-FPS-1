extends BasePlayer
class_name Player

var water_filter : bool = false setget set_water_filter

func _ready():
	pass

func _physics_process(_delta):
	pass
	
func process_commands(delta):
	.process_commands(delta)
	if !state.dead:
		if cmd.next_weapon:
			cmd.primary_fire = false
			cmd.secondary_fire = false
			active_weapon.cmd.primary_fire = false
			active_weapon.cmd.secondary_fire = false
			cmd.next_weapon = false
			if active_weapon_index >= weapons.size() - 1:
				active_weapon_index = 0
				equip_weapon(active_weapon_index)
			else:
				active_weapon_index += 1
				equip_weapon(active_weapon_index)

func set_water_filter(value):
	water_filter = value
	rpc("set_water_filter", value)

# For type checking
func check_player():
	return true
