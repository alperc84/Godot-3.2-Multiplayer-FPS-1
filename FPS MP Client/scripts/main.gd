extends Node

# Here we can specify the public IP address for playing through the internet.
export var ip : String = "localhost"
# Port must be the same as the server's.
const PORT = 27015

var enet : NetworkedMultiplayerENet
var my_id : int = -1
var me_created : bool = false

onready var message = $ui/message
onready var player_scn = preload("res://scenes/player/player.tscn")
onready var puppet_scn = preload("res://scenes/player/puppet.tscn")

func _ready():
	get_tree().set_auto_accept_quit(false)
	# Connecting network and button events
	var _player_connected = get_tree().connect("network_peer_connected", self, "_on_player_connected")
	var _player_disconnected = get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	var _connected_to_server = get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	var _connection_failed = get_tree().connect("connection_failed", self, "_on_connection_failed")
	var _server_disconnected = get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	var _button_pressed = $ui/button.connect("pressed", self, "_on_connect_pressed")
	# Creating a new network instance
	enet = NetworkedMultiplayerENet.new()
	# Setting the anti-aliasing. TODO: settings
	get_viewport().msaa = Viewport.MSAA_8X

func _on_connection_failed():
	display_message("Connection failed!")
	get_tree().set_network_peer(null)

func _on_connected_to_server():
	my_id = get_tree().get_network_unique_id()
	display_message("Connection established. Your id is " + str(my_id))
	# Upon successful connection create a player instance and set it's camera to active
	var player = player_scn.instance()
	player.set_name(str(my_id))
	$players.add_child(player)
	player.get_node("head/camera").current = true
	me_created = true

func _on_server_disconnected():
	display_message("Server disconnected.")

func _on_player_connected(id):
	if me_created:
		var player = puppet_scn.instance()
		player.set_name(str(id))
		$players.add_child(player)

func _on_player_disconnected(id):
	for n in $players.get_children():
		if int(n.name) == id:
			$players.remove_child(n)
			n.queue_free()

func _on_connect_pressed():
	$ui/button.visible = false
	display_message("Connecting...")
	if !ip.is_valid_ip_address():
		display_message("IP is invalid!")
	var _client_created = enet.create_client(ip, PORT)
	get_tree().set_network_peer(enet)

func display_message(text : String):
	$ui/message.text = text

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit()

# Server calls this function upon connection
puppet func create_bots(bot_names):
	for n in bot_names:
		var bot = puppet_scn.instance()
		$bots.add_child(bot)
		bot.name = n
