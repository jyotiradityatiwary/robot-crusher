extends Control

## Config Options
const SERVER_ADDRESS: String = "127.0.0.1"
const SERVER_PORT: int = 8910
const JOINING_ADDRESS: String = SERVER_ADDRESS
const JOINING_PORT: int = SERVER_PORT
const SERVER_MAX_CLIENTS: int = 4
	# Must use this same compression mode on client also
const SERVER_COMPRESSION_MODE: ENetConnection.CompressionMode = \
	ENetConnection.COMPRESS_NONE
const SPAWN_MARKER_HORIZONTAL_SHIFT: float = 300.0
const CAMERA_LIMIT_BOTTOM: int = 720

# Script wide constants
	# RPC Transfer Channels
enum TransferChannels {SERVER_MESSAGES}
const GAME_SCENE_PATH = "res://src/world/world.tscn"
const SERVER_PEER_ID = 1

# Script wide variables
var is_server_hosted: bool = false
var game_manager: GameManager

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.server_disconnected.connect(server_disconnected)
	game_manager = GameManager.new()

func peer_connected(id: int):
	print("Peer Connected. id = ", id)

func peer_disconnected(id: int):
	print("Peer Disconnected. id = ", id)

func connected_to_server():
	print("Connected to Server")
	announce_player_info()

func connection_failed():
	print("Connection Failed")

func server_disconnected():
	print("Server Disconnected")

func announce_player_info():
	var player_name = $NameLineEdit.text
	if player_name == "":
		player_name = "Anon"
	var robot_type = GameManager.RobotType.BLUE # TODO
	if multiplayer.is_server():
		# If we are the server we do not need to make an rpc call.
		# Just call the function locally
		initialize_player_on_server( \
			multiplayer.get_unique_id(), player_name, robot_type)
	else:
		# If we are a client, make an rpc call to the server
		initialize_player_on_server.rpc_id(SERVER_PEER_ID, \
			multiplayer.get_unique_id(), player_name, robot_type)

# Start game in all clients and host
@rpc("authority", "call_local", "reliable", TransferChannels.SERVER_MESSAGES)
func start_game():
	# Load game scene
	var game_scene: Node2D = load(GAME_SCENE_PATH).instantiate()
	# Make game scene visible
	get_tree().root.add_child(game_scene)
	# Hide the main menu
	self.hide()
	# Get spawn marker from the game scene
	var spawn_marker: Marker2D = game_scene.find_child("SpawnMarker", false)
	var my_id: int = multiplayer.get_unique_id()
	# Spawn and setup a player for each peer
	for player_id in game_manager.players:
		# Get player object from array
		var player: GameManager.GamePlayer = game_manager.players[player_id]
		var player_scene: PackedScene = load(GameManager.scene_from_robot_type[player.robot_type])
		# instantiate node for corresponding player object
		var player_node: CharacterBody2D = player_scene.instantiate()
		# assign player_name to player node
		player_node.player_name = player.name
		# get multiplayer synchronizer node of corresponding player node
		var multiplayer_synchronizer: MultiplayerSynchronizer = player_node. \
			find_child("MultiplayerSynchronizer", false)
		# make the corresponding player's id the authority for controlling this
		# 	player node
		multiplayer_synchronizer.set_multiplayer_authority(player_id)
		if my_id == player_id:
			# make player locally controlled and attatch a camera node
			player_node.is_locally_controlled = true
			var camera: Camera2D = Camera2D.new()
			camera.limit_bottom = CAMERA_LIMIT_BOTTOM
			player_node.add_child(camera)
		# make player spawn at the spawn marker
		player_node.global_position = spawn_marker.global_position
		# shift the spawn marker for spawning next player
		spawn_marker.global_position.x += SPAWN_MARKER_HORIZONTAL_SHIFT
		# make the player show up
		game_scene.add_child(player_node)
		

# The client calls this whenever it connects to the server
@rpc("any_peer", "call_remote", "reliable", TransferChannels.SERVER_MESSAGES)
func initialize_player_on_server(id: int, player_name: String, robot_type: GameManager.RobotType):
	# Initialize existing players on the new peer
	for player_id: int in game_manager.players:
		var player: GameManager.GamePlayer = game_manager.players[player_id]
		initialize_plyaer_on_client.rpc_id(id, player_id, player.name, player.robot_type)
	# Add player on the server
	game_manager.add_player(id, GameManager.GamePlayer.create(player_name, robot_type))
	initialize_plyaer_on_client.rpc(id, player_name, robot_type)

# Server calls this to all clients after a new client connects to server
@rpc("authority", "call_remote", "reliable", TransferChannels.SERVER_MESSAGES)
func initialize_plyaer_on_client(id: int, player_name: String, robot_type: GameManager.RobotType):
	game_manager.add_player(id, GameManager.GamePlayer.create(player_name, robot_type))

func _on_host_button_pressed():
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(SERVER_PORT, SERVER_MAX_CLIENTS)
	if error != OK :
		print("Error: Could not create server. details: ", error)
		return
	
	peer.get_host().compress(SERVER_COMPRESSION_MODE)
	multiplayer.set_multiplayer_peer(peer)
	is_server_hosted = true
	print("Server Started")
	announce_player_info()


func _on_join_button_pressed():
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(JOINING_ADDRESS, JOINING_PORT)
	if error != OK:
		print("Error: Could not create client. details: ", error)
	peer.get_host().compress(SERVER_COMPRESSION_MODE)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_button_pressed():
	#print("is server:", multiplayer.is_server(), "\tid:", multiplayer.get_unique_id())
	if not is_server_hosted:
		print("Error: Server has not been hosted by us. Consider hosting or joining.")
		return
	if not multiplayer.is_server():
		print("Error: Only server can start the game. We are not a server.")
		return
	start_game.rpc()
