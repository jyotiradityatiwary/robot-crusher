extends Control

@onready var multiplayer_manager: MultiplayerManager = $/root/MultiplayerManager
@onready var start_game_button: Button = $MarginContainer/VBoxContainer/StartGameButton

func _ready():
	if multiplayer.is_server():
		start_game_button.show()
		start_game_button.grab_focus()


func _on_start_game_button_pressed():
	multiplayer_manager.start_game_for_everyone()
