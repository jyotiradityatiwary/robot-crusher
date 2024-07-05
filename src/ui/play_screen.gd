extends Control

@export var host_screen: PackedScene
@export var join_screen: PackedScene

@onready var multiplayer_manager: MultiplayerManager = $/root/MultiplayerManager
@onready var player_name_text_edit: TextEdit = $MarginContainer/VBoxContainer/HSplitContainer/PlayerNameTextEdit
@onready var host_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/HostButton

func _ready():
	host_button.grab_focus()

func _on_host_button_pressed():
	get_tree().change_scene_to_packed(host_screen)


func _on_join_button_pressed():
	get_tree().change_scene_to_packed(join_screen)


func _on_player_name_text_edit_text_set():
	_set_player_name()


func _on_player_name_text_edit_text_changed():
	_set_player_name()

func _set_player_name():
	multiplayer_manager.player_name = player_name_text_edit.text
