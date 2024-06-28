extends State
class_name LocalControlledState

const FRICTION: float = 5000.0

# This state can only be used with CharacterBody2D's that have their their
# position synced in multiplayer mode.

func process_physics(delta: float) -> State:
	if controlled_node.is_on_floor():
		controlled_node.velocity.x = move_toward(controlled_node.velocity.x, \
			0.0, FRICTION * delta)

	controlled_node.multiplayer_data.global_position = controlled_node.global_position
	return null
