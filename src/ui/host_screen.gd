extends Control

@export var waiting_screen: PackedScene

const SERVER_PORT: int = 8910
const SERVER_MAX_CLIENTS: int = 4

@onready var multiplayer_manager: MultiplayerManager = $/root/MultiplayerManager
@onready var start_server_button: Button = $MarginContainer/VBoxContainer/StartServerButton

func _ready():
	start_server_button.grab_focus()

func _on_start_server_button_pressed():
	multiplayer_manager.host_server(SERVER_PORT, SERVER_MAX_CLIENTS)
	get_tree().change_scene_to_packed(waiting_screen)
