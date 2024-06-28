extends Control

@export var waiting_screen: PackedScene

const SERVER_PORT: int = 8910
const SERVER_MAX_CLIENTS: int = 4

@onready var multiplayer_manager: MultiplayerManager = $/root/MultiplayerManager
@onready var join_server_button: Button = $MarginContainer/VBoxContainer/JoinServerButton

func _ready():
	join_server_button.grab_focus()

func _on_join_server_button_pressed():
	var server_ip_addr = $MarginContainer/VBoxContainer/HSplitContainer/IPAddrTextEdit.text
	multiplayer_manager.join_server(server_ip_addr, SERVER_PORT)
	get_tree().change_scene_to_packed(waiting_screen)
