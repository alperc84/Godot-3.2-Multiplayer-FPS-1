extends Spatial
class_name Character

# This is a scene used to represent a character mesh for players and bots.

# Colors
var actor : BasePlayer
var visible_to_camera : bool setget set_visible_to_camera

func _ready():
	actor = get_owner()
	randomize()
	var random_color = Color(rand_range(0, 1.0), rand_range(0, 1.0), rand_range(0, 1.0))
	$skeleton/mesh.get_surface_material(0).set("shader_param/color_b", random_color)
	$skeleton/mesh.get_surface_material(0).set("shader_param/color_c", random_color.darkened(0.25))
	$skeleton/mesh.get_surface_material(0).set("shader_param/color_d", random_color.darkened(0.5))
	set_visible_to_camera(true)

# Set mesh visibility to player's camera.
# Because we don't want to see the player's mesh by default.
# Only in ragdoll state.
func set_visible_to_camera(b):
	$skeleton/mesh.set_layer_mask_bit(0, b)
	$skeleton/mesh.set_layer_mask_bit(10, !b)
