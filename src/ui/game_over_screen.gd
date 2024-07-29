extends Control

@onready var multiplayer_manager: MultiplayerManager = $/root/MultiplayerManager
@onready var disconnect_button: Button = $MarginContainer/VBoxContainer/HSplitContainer/DisconnectButton
@onready var restart_game_button: Button = $MarginContainer/VBoxContainer/HSplitContainer/RestartGameButton
@onready var info_label: RichTextLabel = $MarginContainer/VBoxContainer/InfoLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer_manager.top_level_node.multiplayer.is_server():
		disconnect_button.text = 'Close Server'
		info_label.text += '\n\n [center]You can restart the game or close the server. Note that any of the above actions will also affect the game for other players who may still be playing[/center]'
		restart_game_button.grab_focus()
	else:
		restart_game_button.hide()
		info_label.text += '\n\n [center]You can wait for the host to restart the game, or disconnect from the server[/center]'
		disconnect_button.grab_focus()


func _on_disconnect_button_pressed():
	if multiplayer_manager.top_level_node.multiplayer.is_server():
		multiplayer_manager.reset_to_title_screen.rpc()
	else:	
		multiplayer_manager.reset_to_title_screen()
