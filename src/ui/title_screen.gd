extends Control

@export_file("*.tscn") var play_screen_path: String
@export_file("*.tscn") var options_screen_path: String
@export_file("*.tscn") var credits_screen_path: String
@export var author_website: String
@export var game_website: String

@onready var play_button: Button = $MarginContainer/HSplitContainer/VBoxContainer/PlayButton

func _ready():
	play_button.grab_focus()

func _on_play_button_pressed():
	# Next screen
	var play_screen_scene: PackedScene = load(play_screen_path)
	var play_screen_node: Control = play_screen_scene.instantiate()
	get_parent().add_child(play_screen_node)
	queue_free()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_author_name_button_pressed():
	OS.shell_open(author_website)

func _on_version_button_pressed():
	OS.shell_open(game_website)

func _initialize_multiplayer_manager():
	pass


func _on_options_button_pressed():
	OS.alert('This screen has not yet been implemented', 'Work in Progress') # Replace with function body.


func _on_credits_button_pressed():
	OS.alert('This screen has not yet been implemented', 'Work in Progress') # Replace with function body.
