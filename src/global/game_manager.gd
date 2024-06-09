extends Object

class_name GameManager

enum RobotType {BLUE}

static func get_name_of_robot_type(robot_type: RobotType) -> String:
	if robot_type is int and robot_type in range(0, RobotType.size()):
		return str(RobotType.keys()[robot_type])
	else:
		return "Invalid RobotType(" + str(robot_type) + ")"

class GamePlayer:
	var name: String
	var robot_type: RobotType
	var score: float
	static func create(_name: String, _robot_type: RobotType) -> GamePlayer:
		var game_player = GamePlayer.new()
		game_player.name = _name
		game_player.robot_type = _robot_type
		game_player.score = 0.0
		return game_player
	func _to_string() -> String:
		return "GamePlayer(name=\"" + self.name + "\", robot_type=" + \
			GameManager.get_name_of_robot_type(self.robot_type) + ", score=" + str(self.score)  + \
			")"

var players: Dictionary = {}

func add_player(id: int, game_player: GamePlayer) -> Error:
	if id in self.players:
		push_error("Error: id already in use")
		return FAILED
	
	self.players[id] = game_player
	return OK

func remove_player_if_exists(id: int):
	players.erase(id)

func remove_player(id: int):
	if not players.erase(id):
		push_error("Error: Could not remove player because player does not exist")
