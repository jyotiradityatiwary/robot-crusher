extends CanvasLayer

@export var joystick_root_node: TouchScreenButton
@export var stick_node: Sprite2D
@export var jump_button: TouchScreenButton

@export_category("Input Map")
@export var move_right_action: StringName
@export var move_left_action: StringName
@export var move_down_action: StringName
@export var move_up_action: StringName
@export var jump_action: StringName

var joystick_offset: Vector2 = Vector2.ZERO
var joystick_max_offset_length: float
var joystick_root_center: Vector2
var joystick_detection_radius: float

# Called when the node enters the scene tree for the first time.
func _ready():
	if not DisplayServer.is_touchscreen_available() :
		queue_free()
	var joystick_texture_normal: Texture2D = joystick_root_node.texture_normal
	var joystick_root_center_offset: Vector2 = (
		Vector2(
			joystick_texture_normal.get_height(),
			joystick_texture_normal.get_width()
		) * joystick_root_node.scale
	) / 2
	joystick_max_offset_length = joystick_root_center_offset.x
	joystick_root_center = joystick_root_node.global_position + joystick_root_center_offset
	joystick_detection_radius = (joystick_root_node.shape as CircleShape2D).radius * joystick_root_node.scale.x

func _input(event: InputEvent):
	handle_movement(event)

func handle_movement(event: InputEvent):
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag) :
		return
	
	if not joystick_root_node.is_pressed() :
		return
	
	var raw_joystick_offset = (event.position as Vector2 - joystick_root_center)
	
	if raw_joystick_offset.length() > joystick_detection_radius:
		return
	
	joystick_offset = raw_joystick_offset.limit_length(joystick_max_offset_length)
	stick_node.position = joystick_offset * stick_node.scale
	
	var x_intensity: float = joystick_offset.x / joystick_max_offset_length
	var y_intensity: float = joystick_offset.y / joystick_max_offset_length
	
	if x_intensity > 0:
		Input.action_press(move_right_action, x_intensity)
	else:
		Input.action_release(move_right_action)
	
	if x_intensity < 0:
		Input.action_press(move_left_action, - x_intensity)
	else:
		Input.action_release(move_left_action)
	
	if y_intensity > 0:
		Input.action_press(move_down_action, y_intensity)
	else:
		Input.action_release(move_down_action)
	
	if y_intensity < 0:
		Input.action_press(move_up_action, - y_intensity)
	else:
		Input.action_release(move_up_action)

func _on_movement_touch_screen_button_released() -> void:
	for action: StringName in [
		move_down_action, move_up_action, move_left_action, move_right_action
	]:
		Input.action_release(action)
	stick_node.position = Vector2.ZERO
