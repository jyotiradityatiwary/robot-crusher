extends Node
class_name  StateMachine

@export var starting_state: State

var current_state: State

# Call this from _ready()
func initialize_for(controlled_node: CharacterBody2D):
	for child: Node in get_children():
		if child is State:
			child.controlled_node = controlled_node
	current_state = starting_state
	current_state.enter()

# Usually not for external use. Used internally by process_* functions
# of this class
func change_state(to_state: State) -> void:
	current_state.exit()
	current_state = to_state
	current_state.enter()

# Call from _physics_process(delta) of parent node
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

# Call from _process(delta) of parent node
func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)
