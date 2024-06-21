extends Node
class_name State

# This class should not be used directly unless you need a dead state.
# Extend this class and override the methods to implement desired behavior.

var controlled_node: CharacterBody2D

func enter() -> void:
	pass

func exit() -> void:
	pass

# The returned state will be set as the new current state by the parent
# state machine 
func process_physics(_delta: float) -> State:
	return null

func process_frame(_delta: float) -> State:
	return null

func process_input(_event: InputEvent) -> State:
	return null
