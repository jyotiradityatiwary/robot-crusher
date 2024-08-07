extends State
class_name DashChargingState

@export var free_fall_state: State

const DASH_MAX_SPEED: float = 2000
const DASH_CHARGE_RATE: float = 1

const MOVE_LEFT_INPUT_NAME: StringName = &"move_left"
const MOVE_RIGHT_INPUT_NAME: StringName = &"move_right"
const MOVE_UP_INPUT_NAME: StringName = &"move_up"
const MOVE_DOWN_INPUT_NAME: StringName = &"move_down"

var dash_charge: float = 0.0 :
	set (value):
		dash_charge = value
		controlled_node.dash_progress_bar.value = dash_charge

func enter() -> void:
	controlled_node.dash_progress_bar.show()
	dash_charge = 0.0

func exit() -> void:
	if dash_charge > 1.0:
		dash_charge = 1.0
	var dash_direction: Vector2 = Input.get_vector(MOVE_LEFT_INPUT_NAME, MOVE_RIGHT_INPUT_NAME, \
		MOVE_UP_INPUT_NAME, MOVE_DOWN_INPUT_NAME).normalized()
	if dash_direction.x != 0 :
		controlled_node.set_is_facing_left(dash_direction.x < 0)
	controlled_node.velocity += dash_charge * DASH_MAX_SPEED * dash_direction
	controlled_node.move_and_slide()
	controlled_node.dash_progress_bar.hide()

func process_physics(delta: float) -> State:
	if not controlled_node.is_on_floor():
		dash_charge = 0
		return free_fall_state
	if dash_charge < 1.0:
		dash_charge += DASH_CHARGE_RATE * delta
		controlled_node.dash_progress_bar.value = dash_charge
	controlled_node.move_and_slide()
	return null

func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_released("dash"):
		return free_fall_state
	return null
