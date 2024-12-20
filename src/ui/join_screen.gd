extends Control

@export_file('*.tscn') var waiting_screen: String
@export var join_server_button: Button
@export var ip_text_edit: TextEdit
@export var port_text_edit: TextEdit

@onready var multiplayer_manager: MultiplayerManager = get_parent() \
	.find_child("MultiplayerManager", false)

func _ready():
	join_server_button.grab_focus()

func _on_join_server_button_pressed():
	# Read port number
	var port_text: String = port_text_edit.text
	if not port_text.is_valid_int():
		OS.alert("Port must be an integer", "Invalid Input")
		return
	var port: int = port_text.to_int()
	if port < 0 or port > 65535:
		OS.alert("Port number out of range. Pick a number between 1024 and 65535", "Invalid Input")
		return
	if port < 1024:
		OS.alert("Don't use privileged ports please (port numbers less than 1024 are reserved for system use)", "Invalid Input")
		return
	
	# Read IP Address
	var server_ip_addr = ip_text_edit.text
	multiplayer_manager.join_server(server_ip_addr, port)
	get_parent().add_child(load(waiting_screen).instantiate())
	queue_free()
