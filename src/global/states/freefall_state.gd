extends State
class_name FreeFallState

@export var sliding_state: State

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# The returned state will be set as the new current state by the parent
# state machine 
func process_physics(delta: float) -> State:
	controlled_node.velocity.y += gravity * delta
	controlled_node.move_and_slide()
	if controlled_node.is_on_floor():
		return sliding_state
	return null
