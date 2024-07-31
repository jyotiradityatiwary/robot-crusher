extends Control

@export var play_screen: PackedScene
@export var options_screen: PackedScene
@export var credits_screen: PackedScene
@export var author_website: String
@export var game_website: String

@export_category("Multiplayer Manager")
# These variables will be used to set up the multiplayer manager
@export var game_scene: PackedScene
@export_file('*.tscn') var game_over_scene_path: String
@export_file('*.tscn') var title_scene_path: String

@onready var play_button: Button = $MarginContainer/HSplitContainer/VBoxContainer/PlayButton

func _ready():
	play_button.grab_focus()

func _on_play_button_pressed():
	# Initialize multiplayer manager
	var multiplayer_manager: MultiplayerManager = MultiplayerManager.new()
	multiplayer_manager.name = "MultiplayerManager"
	multiplayer_manager.game_scene = game_scene
	multiplayer_manager.game_over_scene_path = game_over_scene_path
	multiplayer_manager.title_scene_path = title_scene_path
	# This is addedd to the tree before the next scene so that it stays at top
	get_tree().root.add_child(multiplayer_manager)
	
	# Next screen
	get_tree().change_scene_to_packed(play_screen)

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
