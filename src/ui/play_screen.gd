extends Control

@export_file('*.tscn') var host_screen: String
@export_file('*.tscn') var join_screen: String

@onready var multiplayer_manager: MultiplayerManager = get_parent() \
	.find_child("MultiplayerManager", false)
@onready var player_name_text_edit: TextEdit = $MarginContainer/VBoxContainer/HSplitContainer/PlayerNameTextEdit
@onready var host_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/HostButton

func _ready():
	host_button.grab_focus()

func _on_host_button_pressed():
	get_parent().add_child(load(host_screen).instantiate())
	queue_free()

func _on_join_button_pressed():
	get_parent().add_child(load(join_screen).instantiate())
	queue_free()

func _on_player_name_text_edit_text_set():
	_set_player_name()

func _on_player_name_text_edit_text_changed():
	_set_player_name()

func _set_player_name():
	multiplayer_manager.player_name = player_name_text_edit.text
