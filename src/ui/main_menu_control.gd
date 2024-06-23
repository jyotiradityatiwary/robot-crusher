extends Control

## Hardcoded Config Options
const SERVER_ADDRESS: String = "127.0.0.1"
const SERVER_PORT: int = 8910
const JOINING_ADDRESS: String = SERVER_ADDRESS
const JOINING_PORT: int = SERVER_PORT
const SERVER_MAX_CLIENTS: int = 4

@onready var name_line_edit: LineEdit = $NameLineEdit
@onready var multiplayer_manager: MultiplayerManager = $MultiplayerManager

func set_player_details() -> void:
	multiplayer_manager.player_name = name_line_edit.text
	multiplayer_manager.robot_type = GameManager.RobotType.BLUE

func _on_host_button_pressed():
	multiplayer_manager.host_server(SERVER_PORT, SERVER_MAX_CLIENTS)

func _on_join_button_pressed():
	multiplayer_manager.join_server(SERVER_ADDRESS, SERVER_PORT)

func _on_start_button_pressed():
	multiplayer_manager.start_game_for_everyone()
