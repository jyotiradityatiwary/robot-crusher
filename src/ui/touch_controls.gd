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


# Called when the node enters the scene tree for the first time.
func _ready():
	if not DisplayServer.is_touchscreen_available() :
		queue_free()
	var joystick_root_center_offset: Vector2 = (
		Vector2(
			joystick_root_node.texture_normal.get_height(),
			joystick_root_node.texture_normal.get_width()
		) * joystick_root_node.scale
	) / 2
	joystick_max_offset_length = joystick_root_center_offset.x
	joystick_root_center = joystick_root_node.global_position + joystick_root_center_offset

func _input(event: InputEvent):
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag) :
		return
	
	if joystick_root_node.is_pressed() :
		joystick_offset = (
			event.position as Vector2 - joystick_root_center
		).limit_length(joystick_max_offset_length)
		print("offset = ", joystick_offset)
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
			Input.action_press("move_down", y_intensity)
		else:
			Input.action_release(move_down_action)
		
		if y_intensity < 0:
			Input.action_press(move_up_action, - y_intensity)
		else:
			Input.action_release(move_up_action)
	
	#if (event.position - $"Attack Button".position - Vector2(12,12)).length() < 48 :
		#if $"Attack Button".is_pressed() :
			#Input.action_press("Attack")
		#else :
			#Input.action_release("Attack")


func _on_movement_touch_screen_button_released() -> void:
	for action: StringName in [
		move_down_action, move_up_action, move_left_action, move_right_action
	]:
		Input.action_release(action)
	stick_node.position = Vector2.ZERO
