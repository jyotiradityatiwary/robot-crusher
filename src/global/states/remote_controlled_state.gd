extends State
class_name RemoteControlledState

# This state can only be used with CharacterBody2D's that have their their
# position synced in multiplayer mode.

const MULTIPLAYER_POSITION_LERP_WEIGHT: float = 0.7

func process_physics(_delta: float) -> State:
	controlled_node.global_position = controlled_node.global_position.lerp( \
		controlled_node.synced_global_position, \
		MULTIPLAYER_POSITION_LERP_WEIGHT)
	return null
