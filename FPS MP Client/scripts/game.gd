extends Node

# This script is global. It autoloads and we can access it from other scripts.

# Main and world scenes for quick access.
onready var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)

func _ready():
	pass
