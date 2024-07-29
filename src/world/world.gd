extends Node2D

@export var camera_limit_bottom: int
@export var spawn_marker_shift: Vector2

# the following variables are to be initialized by whatever function sets up this level
var game_over_scene: PackedScene

func _enter_tree():
	var robot_multiplayer_spawner: MultiplayerSpawner = $RobotMultiplayerSpawner
	var spawn_marker: Marker2D = $SpawnMarker
	robot_multiplayer_spawner.spawn_function = func _multi_spawn_func(data):
		var player_id: int = data[0]
		var player_name: String = data[1]
		var robot_type: GameManager.RobotType = data[2]
		var player_scene: PackedScene = load( \
				GameManager.scene_from_robot_type[robot_type] \
			)
		var player_node: CharacterBody2D = player_scene.instantiate()
		
		player_node.player_name = player_name
		player_node.robot_type = robot_type
		player_node.player_id = player_id
		
		player_node.global_position = spawn_marker.global_position
		spawn_marker.global_position += spawn_marker_shift
		
		player_node.find_child("RobotMultiplayerData", false) \
			.set_multiplayer_authority(player_id)
		
		player_node.is_locally_controlled = player_id == multiplayer.get_unique_id()
		
		if player_node.is_locally_controlled:
			var camera: Camera2D = Camera2D.new()
			camera.limit_bottom = camera_limit_bottom
			camera.position_smoothing_enabled = true
			camera.position_smoothing_speed = 10.0
			player_node.add_child(camera)
		
		return player_node

func gamr_over():
	get_parent().add_child(game_over_scene.instantiate())
	queue_free()
