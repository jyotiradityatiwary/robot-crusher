extends Control

@export_file('*.tscn') var waiting_screen: String
@export var start_server_button: Button
@export var max_clients_text_edit: TextEdit
@export var port_text_edit: TextEdit

@onready var multiplayer_manager: MultiplayerManager = get_parent() \
	.find_child("MultiplayerManager", false)

func _ready():
	start_server_button.grab_focus()

func _on_start_server_button_pressed():
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
	
	# Read max clients
	var max_clients_text: String = max_clients_text_edit.text
	if not max_clients_text.is_valid_int():
		OS.alert("Max clients must be an integer", "Invalid Input")
		return
	var max_clients: int = max_clients_text.to_int()
	if max_clients <= 0:
		OS.alert("Max clients should be a positive integer", "Invalid Input")
		return
	if max_clients > 4096:
		OS.alert("4095 is the theoritcal limit for max clients.", "Invalid Input")
		return

	multiplayer_manager.host_server(port, max_clients)
	get_parent().add_child(load(waiting_screen).instantiate())
	queue_free()
