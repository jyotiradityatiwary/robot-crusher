extends Control

@onready var multiplayer_manager: MultiplayerManager = get_parent() \
	.find_child("MultiplayerManager", false)
@onready var start_game_button: Button = $MarginContainer/VBoxContainer/StartGameButton

func _ready():
	if multiplayer.is_server():
		start_game_button.show()
		start_game_button.grab_focus()


func _on_start_game_button_pressed():
	multiplayer_manager.start_game_for_everyone()
	queue_free()
