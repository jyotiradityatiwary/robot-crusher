extends Object

class_name GameManager
# This a Object and not a Node or a RefernceCounted Object Hence must be freed 
# manually. Not meant to be intefaced directly. The MultiPlayerManager (Node)
# provides abstraction on top of this class and gandles RPC calls.


enum RobotType {BLUE}

static func get_name_of_robot_type(robot_type: RobotType) -> String:
	if robot_type is int and robot_type in range(0, RobotType.size()):
		return str(RobotType.keys()[robot_type])
	else:
		return "Invalid RobotType(" + str(robot_type) + ")"

const scene_from_robot_type: Dictionary = {
	RobotType.BLUE: "res://src/entities/blue_robot.tscn",
}

class GamePlayer:
	var name: String
	var robot_type: RobotType
	var score: float
	var node: Node
	#static func create(_name: String, _robot_type: RobotType) -> GamePlayer:
		#var game_player = GamePlayer.new()
		#game_player.name = _name
		#game_player.robot_type = _robot_type
		#game_player.score = 0.0
		#return game_player
	#
	func _init(_name: String, _robot_type: RobotType):
		self.name = _name
		self.robot_type = _robot_type
		self.score = 0.0
		self.node = null
	
	func _to_string() -> String:
		return "GamePlayer(name=\"" + self.name + "\", robot_type=" + \
			GameManager.get_name_of_robot_type(self.robot_type) + ", score=" + str(self.score)  + \
			")"

var players: Dictionary = {}
var lobby_player_ids: Array[int] = []

func add_player(id: int, game_player: GamePlayer) -> Error:
	if id in self.players:
		push_error("Error: id already in use")
		return FAILED
	
	self.players[id] = game_player
	self.lobby_player_ids.append(id)
	return OK

func set_player_node(player_id: int, node: Node):
	var player: GamePlayer = self.players.get(player_id)
	player.node = node

func get_player_node(player_id: int) -> Node:
	var player: GamePlayer = self.players.get(player_id)
	return player.node

# Returns true if the player was present in the dictionary and was
# successfully deleted
func remove_player_if_exists(id: int) -> bool:
	return players.erase(id)

# Creates error
func remove_player(id: int):
	if not remove_player_if_exists(id):
		push_error("Error: Could not remove player because player does not exist")
