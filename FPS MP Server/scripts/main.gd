extends Node

# Port can be changed. Make sure your ISP doesn't block it. Also open it in the router settings.
const PORT = 27015
const MAX_PLAYERS = 15
const MAX_BOTS = 15
onready var bot_scene = preload("res://scenes/player/bot.tscn")
var bots = []
var spawn_points = []

func _ready():
	# Setting up the network API
	var enet = NetworkedMultiplayerENet.new()
	enet.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(enet)
	# Connecting network events
	var _client_connected = get_tree().connect("network_peer_connected", self, "_on_client_connected")
	var _client_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_client_disconnected")
	# Set spawn and intereset points for players in a global game script
	game.spawn_points = $map/spawn_points.get_children()
	game.interest_points = $map/interest_points.get_children()
	# Create bots
	for i in MAX_BOTS:
		var bot = bot_scene.instance()
		$bots.add_child(bot)
		bot.global_transform.origin = game.spawn_points[randi() % game.spawn_points.size()].global_transform.origin
		bot.name = str($bots.get_children().size())
		bots.push_back(bot.name)

func _on_client_connected(id):
	print("Client " + str(id) + " connected.")
	# Creating a player and setting its name to the ID given by the network API
	var player = load("res://scenes/player/player.tscn").instance()
	player.set_name(str(id))
	$players.add_child(player)
	player.global_transform.origin = game.spawn_points[randi() % game.spawn_points.size()].global_transform.origin
	# Create bot representations for player
	rpc_id(id, "create_bots", bots)

func _on_client_disconnected(id):
	print("Client " + str(id) + " disconnected.")
	# Removing the player resource based on a disconnected ID
	var players = $players.get_children()
	for p in players:
		if int(p.name) == id:
			$players.remove_child(p)
			p.queue_free()
