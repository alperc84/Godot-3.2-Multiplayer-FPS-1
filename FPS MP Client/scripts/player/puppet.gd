extends BasePlayer
class_name Puppet

# This represents other connected players and bots.

func _ready():
	var _state_changed = connect("state_changed", self, "_on_state_changed")

func _physics_process(_delta):
	if active_weapon_index == 0:
		$head/holder.global_transform = $character/skeleton/hand_r/shotgun.global_transform
	elif active_weapon_index == 1:
		$head/holder.global_transform = $character/skeleton/hand_r/smg.global_transform
	else:
		$head/holder.global_transform = $character/skeleton/hand_r/shotgun.global_transform
	anim_tree["parameters/aim_y/add_amount"] = head.rotation.x

func _on_state_changed(s, _b):
	match s:
		"dead":
			if state[s]:
				enable_ragdoll_collisions(true)
				$shape.disabled = true
				$character/skeleton.physical_bones_start_simulation()
				$character/skeleton/pb_spine.apply_central_impulse(last_impulse)
			else:
				enable_ragdoll_collisions(false)
				$shape.disabled = false
				$character/skeleton.physical_bones_stop_simulation()

func process_commands(_delta):
	pass

func process_movement(_delta):
	pass

func check_pos_on_server():
	pass

func process_rotations(_x : float, _y : float):
	pass

# Here we are updating the position, rotation, head rotation, velocity, acceleration and input vector
puppet func update_puppet(pos : Vector3, rot : Vector3, h_rot : Vector3, v : Vector3, a : float, imv : Vector2):
	translation = pos
	rotation = rot
	head.rotation = h_rot
	vel = v
	accel = a
	input_movement_vector = imv
