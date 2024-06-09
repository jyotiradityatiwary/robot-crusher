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

@rpc("authority", "call_local", "reliable", TransferChannels.SERVER_MESSAGES)
func start_game():
	var scene = load(GAME_SCENE_PATH).instantiate()
	get_tree().root.add_child(scene)
	self.hide()
	print(game_manager.players)

#@rpc("any_peer", "call_remote", "reliable", TransferChannels.SERVER_MESSAGES)
#func send_player_information(id: int, player_name: String, robot_name: GameManager.RobotName):
	#if not game_manager.players.has(id):
		#game_manager.players[id] = {
			#"name" : player_name,
			#"robot_name" : robot_name,
			#"score" : 0
		#}
		#
		#if multiplayer.is_server():
			#send_player_information.rpc(id, name, robot_name)

@rpc("any_peer", "call_remote", "reliable", TransferChannels.SERVER_MESSAGES)
func initialize_player_on_server(id: int, player_name: String, robot_type: GameManager.RobotType):
	# Initialize existing players on the new peer
	for player_id: int in game_manager.players:
		var player: GameManager.GamePlayer = game_manager.players[player_id]
		initialize_plyaer_on_client.rpc_id(id, player_id, player.name, player.robot_type)
	# Add player on the server
	game_manager.add_player(id, GameManager.GamePlayer.create(player_name, robot_type))
	initialize_plyaer_on_client.rpc(id, player_name, robot_type)

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
