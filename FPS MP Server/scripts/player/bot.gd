extends BasePlayer
class_name Bot

const FOV = 90
const PERCEPTION_RANGE = 500
const FIRE_RANGE = 100
const KICK_RANGE = 1

var brain : StackFSM
var target : Spatial
var thinking : bool = false
var navigation : Navigation
var point : Vector3

func _ready():
	# A delay for actions
	var _think_timeout = $timers/think.connect("timeout", self, "_on_think_end")
	# Main state machine
	brain = StackFSM.new()
	add_child(brain)
	brain.push_state("roam")
	# Health
	set_health(100)
	# Navigation
	navigation = game.main.get_node("map/nav")
	# Random weapon
	randomize()
	var random_weapon_index = randi() % 2 + 1
	equip_weapon(random_weapon_index)

func _physics_process(delta):
	target = get_closest()
	# Face camera direction
	rotation.y = lerp_angle(rotation.y, camera.global_transform.basis.get_euler().y, delta * 5)
	# Respawn
	if state.dead and $timers/respawn.time_left <= 0.0:
		cmd.primary_fire = true

func roam():
	# Stop unnecessary movement
	cmd.sprint = false
	cmd.move_left = false
	cmd.move_right = false
	cmd.move_jump = false
	cmd.primary_fire = false
	# Choosing random point from the interest points of the map
	if target:
		brain.push_state("chase")
	if point == Vector3.ZERO:
		point = game.interest_points[randi() % game.interest_points.size()].global_transform.origin
	else:
		# Form the path
		var path = navigation.get_simple_path(global_transform.origin, point, true)
		# If we get a path remove the first closest point and look at further one moving forward
		if path.size() > 1 and translation.distance_to(point) >= 1:
			path.remove(0)
			look_at_point(path[0])
			cmd.move_forward = true
		else:
			cmd.move_forward = false
			point = Vector3.ZERO

func chase():
	cmd.kick = false
	if target == null:
		brain.pop_state()
	elif translation.distance_to(target.translation) > KICK_RANGE:
		var path = navigation.get_simple_path(global_transform.origin, target.global_transform.origin, true)
		if path:
			path.remove(0)
			look_at_point(path[0])
			cmd.move_forward = true
			cmd.sprint = true
			cmd.move_jump = true
			if randi() % 2 == 1:
				cmd.move_left = true
				cmd.move_right = false
			else:
				cmd.move_left = false
				cmd.move_right = true
		else:
			brain.pop_state()
		# Fire
		if translation.distance_to(target.translation) <= FIRE_RANGE:
			if !thinking:
				cmd.primary_fire = true
				thinking = true
				$timers/think.wait_time = rand_range(0.01, 0.05)
				$timers/think.start()
			else:
				cmd.primary_fire = false
	elif randi() % 5 == 1:
		brain.push_state("kick")

func kick():
	# Stop unnecessary movement
	cmd.sprint = false
	cmd.move_forward = false
	cmd.move_left = false
	cmd.move_right = false
	cmd.move_jump = false
	cmd.primary_fire = false
	# Stop rotating
	head.global_transform.basis = global_transform.basis
	if target == null or translation.distance_to(target.translation) > KICK_RANGE:
		cmd.kick = false
		brain.pop_state()
	else:
		look_at_target(target)
		cmd.kick = true

func hit(damage, dealer, pos):
	.hit(damage, dealer, pos)
	target = dealer
	brain.push_state("chase")

func die():
	.die()
	for i in cmd.size():
		cmd[i] = false

func target_is_visible(t, fov, distance):
	var facing = -camera.global_transform.basis.z
	var to_target = t.translation - camera.global_transform.origin
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(camera.global_transform.origin, t.global_transform.origin, [self])
	var result_target : Node
	if result:
		if result.collider is KinematicBody or result.collider is RigidBody:
			result_target = result.collider
	return rad2deg(facing.angle_to(to_target)) < fov and camera.global_transform.origin.distance_to(t.global_transform.origin) <= distance and result_target == t

func look_at_point(p):
	head.look_at(Vector3(p.x, translation.y, p.z), Vector3.UP)

func look_at_target(t):
	head.look_at(Vector3(t.translation.x, translation.y, t.translation.z), Vector3.UP)

func _on_think_end():
	thinking = false

func get_closest():
	var min_dist = INF
	var closest = null
	var players = game.main.get_node("players").get_children() + game.main.get_node("bots").get_children()
	for player in players:
		if player == self:
			continue
		var dist = translation.distance_to(player.translation)
		if dist < min_dist and target_is_visible(player, FOV, PERCEPTION_RANGE) and !player.state.dead:
			min_dist = dist
			closest = player
	return closest

# For type checking
func check_bot():
	return true
