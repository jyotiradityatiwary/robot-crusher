extends Node
class_name RobotMultiplayerData
# This holds data that needs to be synced accross all peers

@onready var parent = $".."

@export var global_position: Vector2
@export var health: float:
	set (new_health) :
		print("my parent is: ", parent)
		if parent == null:
			return
		health = new_health
		parent.health_progress_bar.value = new_health
