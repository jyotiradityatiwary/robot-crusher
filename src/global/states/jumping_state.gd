extends State
class_name JumpingState

@export var free_fall_state: State

const MAX_JUMP_DURATION: float = - 1000.0
const INITIAL_JUMP_ACCELERATION: float = - 8000.0
const JUMP_ACCELERATION_DAMP: float = 40000.0

const JUMP_INPUT_NAME = &"jump"

var jump_acceleration: float

func enter() -> void:
	controlled_node.sprite.texture = preload("res://assets/robots/side_view/robot_blueJump.png")
	jump_acceleration = INITIAL_JUMP_ACCELERATION

func exit() -> void:
	controlled_node.sprite.texture = preload("res://assets/robots/side_view/robot_blueDrive1.png")

func process_physics(delta: float) -> State:
	if jump_acceleration >= 0:
		return free_fall_state
	controlled_node.velocity.y += jump_acceleration * delta
	jump_acceleration = move_toward(jump_acceleration, 0.0, JUMP_ACCELERATION_DAMP * delta)
	controlled_node.move_and_slide()
	return null

func process_input(_event: InputEvent) -> State:
	if Input.is_action_just_released(JUMP_INPUT_NAME):
		return free_fall_state
	return null
