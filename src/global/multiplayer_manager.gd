extends Node
class_name MultiplayerManager

## Config Options
# These variables are set by whatever function sets up this scene.
# In this case, it would probably be the title screen.
	# Must use this same compression mode on client also
var server_compression_mode: ENetConnection.CompressionMode = \
	ENetConnection.COMPRESS_NONE
var game_scene: PackedScene
var game_over_scene_path: String
var title_scene_path: String

# Script wide constants
	# RPC Transfer Channels
enum TransferChannels {SERVER_MESSAGES}
const SERVER_PEER_ID = 1

# Script wide variables
var is_server_hosted: bool = false
var game_manager: GameManager

# Properties for the player using current device. Have default values but should
# be overriden by the top level node, i.e, the node controlling this class
var player_name: String = "anon"
var robot_type: GameManager.RobotType = GameManager.RobotType.BLUE

# This is usually the main meny control screen
var top_level_node: Node

func _ready() -> void:
	top_level_node = get_parent()
	top_level_node.multiplayer.peer_connected.connect(peer_connected)
	top_level_node.multiplayer.peer_disconnected.connect(peer_disconnected)
	top_level_node.multiplayer.connected_to_server.connect(connected_to_server)
	top_level_node.multiplayer.connection_failed.connect(connection_failed)
	top_level_node.multiplayer.server_disconnected.connect(server_disconnected)
	game_manager = GameManager.new()

func _exit_tree() -> void:
	game_manager.free()

func peer_connected(id: int) -> void:
	print("Peer Connected. id = ", id)

func peer_disconnected(id: int) -> void:
	print("Peer Disconnected. id = ", id)

func connected_to_server() -> void:
	print("Connected to Server")
	announce_player_info()

func connection_failed() -> void:
	print("Connection Failed")

func server_disconnected() -> void:
	print("Server Disconnected")

# This function is intended to be called from controlling parent script.
# This starts a server on the current device and waits for connections
func host_server(server_port: int, server_max_clients: int) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(server_port, server_max_clients)
	if error != OK :
		print("Error: Could not create server. details: ", error)
		return
	
	peer.get_host().compress(server_compression_mode)
	top_level_node.multiplayer.set_multiplayer_peer(peer)
	is_server_hosted = true
	print("Server Started")
	announce_player_info()

# This function is intended to be called from controlling parent script.
# This joins an existing server on the given ip address and port
func join_server(server_address, server_port: int) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(server_address, server_port)
	if error != OK:
		print("Error: Could not create client. details: ", error)
	peer.get_host().compress(server_compression_mode)
	top_level_node.multiplayer.set_multiplayer_peer(peer)

func start_game_for_everyone() -> void:
	if not is_server_hosted:
		print("Error: Server has not been hosted by us. Consider hosting or joining.")
		return
	if not top_level_node.multiplayer.is_server():
		print("Error: Only server can start the game. We are not a server.")
		return

	_start_game_on_client.rpc()
	
	var game_scene_node: Node2D = $/root/World
	var multiplayer_spawner: MultiplayerSpawner = game_scene_node.find_child("RobotMultiplayerSpawner", false)
	
	## Spawn and setup a player for each peer
	for player_id in game_manager.players:
		# Get player object from array
		var player_data: GameManager.GamePlayer = game_manager.players[player_id]
		multiplayer_spawner.spawn([player_id, player_data.name, player_data.robot_type])

func announce_player_info() -> void:
	if top_level_node.multiplayer.is_server():
		# If we are the server we do not need to make an rpc call.
		# Just call the function locally
		initialize_player_on_server( \
			top_level_node.multiplayer.get_unique_id(), player_name, robot_type)
	else:
		# If we are a client, make an rpc call to the server
		initialize_player_on_server.rpc_id(SERVER_PEER_ID, \
			top_level_node.multiplayer.get_unique_id(), player_name, robot_type)

# Start game in all clients and host
@rpc("authority", "call_local", "reliable", TransferChannels.SERVER_MESSAGES)
func _start_game_on_client() -> void:
	var waiting_screen_node: Control = $/root/WaitingScreen
	waiting_screen_node.get_parent().remove_child(waiting_screen_node)
	waiting_screen_node.queue_free()
	var game_scene_node: Node2D = game_scene.instantiate()
	get_tree().root.add_child(game_scene_node)

# The client calls this whenever it connects to the server
@rpc("any_peer", "call_remote", "reliable", TransferChannels.SERVER_MESSAGES)
func initialize_player_on_server( \
		_id: int, \
		_player_name: String, \
		_robot_type: GameManager.RobotType \
	) -> void:
	# Initialize existing players on the new peer
	for player_id: int in game_manager.players:
		var player: GameManager.GamePlayer = game_manager.players[player_id]
		initialize_plyaer_on_client.rpc_id(_id, player_id, player.name, player.robot_type)
	# Add player on the server
	game_manager.add_player(_id, GameManager.GamePlayer.new(_player_name, _robot_type))
	initialize_plyaer_on_client.rpc(_id, _player_name, _robot_type)

# Server calls this to all clients after a new client connects to server
@rpc("authority", "call_remote", "reliable", TransferChannels.SERVER_MESSAGES)
func initialize_plyaer_on_client( \
		_id: int, \
		_player_name: String, \
		_robot_type: GameManager.RobotType \
	) -> void:
	game_manager.add_player(_id, GameManager.GamePlayer.new(_player_name, _robot_type))

func kill_player(player_node: Node, multiplayer_id: int):
	# because we are using MultiplayerSpawner, we only need to kill the node on
	# the server and it will be synced across all peers
	print("kill player called with args: ", player_node, ", ", multiplayer_id)
	
	if top_level_node.multiplayer.is_server():
		player_node.queue_free()
		go_to_game_over_screen.rpc_id(multiplayer_id)

@rpc("authority", "call_local", "reliable", TransferChannels.SERVER_MESSAGES)
func go_to_game_over_screen():
	var game_scene_node: Node2D = $/root/World
	$/root.add_child(load(game_over_scene_path).instantiate())
	if not top_level_node.multiplayer.is_server():
		# We cannot queue free the game on the server because this will make all
		# other players despawn
		game_scene_node.queue_free()

@rpc("authority", "call_local", "reliable", TransferChannels.SERVER_MESSAGES)
func reset_to_title_screen():
	var root: Node = get_tree().root
	var title_screen: Control = load(title_scene_path).instantiate()
	# Connect title screen
	root.add_child(title_screen)
	# Remove all other children from root
	for child: Node in root.get_children(false):
		if child != title_screen:
			child.queue_free()
