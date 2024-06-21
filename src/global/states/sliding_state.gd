extends State
class_name SlidingState

@export var free_fall_state: State
@export var jumping_state: State
@export var dash_charging_state: State

const ACCELERATION: float = 6000.0

const MOVE_LEFT_INPUT_NAME: StringName = &"move_left"
const MOVE_RIGHT_INPUT_NAME: StringName = &"move_right"
const JUMP_INPUT_NAME: StringName = &"jump"
const DASH_INPUT_NAME: StringName = &"dash"

var direction: float = 0

func process_physics(delta: float) -> State:
	controlled_node.velocity.x += direction * ACCELERATION * delta
	if not controlled_node.is_on_floor():
		return free_fall_state
	controlled_node.move_and_slide()
	return null

func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_pressed(JUMP_INPUT_NAME):
		return jumping_state
	if Input.is_action_just_pressed(DASH_INPUT_NAME):
		return dash_charging_state
	direction = Input.get_action_strength(MOVE_RIGHT_INPUT_NAME) - Input.get_action_strength(MOVE_LEFT_INPUT_NAME)
	return null
