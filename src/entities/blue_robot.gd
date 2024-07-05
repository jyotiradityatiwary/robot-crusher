extends CharacterBody2D

@export var local_controlled_state: State
@export var free_fall_state: State
@export var robot_type: GameManager.RobotType = GameManager.RobotType.BLUE
@export var camera_limit_bottom: int = 720

var is_locally_controlled: bool = false
var player_name: String
var player_id: int

@onready var movement_state_machine: StateMachine = $MovementStateMachine
@onready var control_state_machine: StateMachine = $ControlStateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var multiplayer_data: RobotMultiplayerData = $RobotMultiplayerData
@onready var player_name_label: Label = $PlayerNameLabel

func _ready():
	player_name_label.text = self.player_name
	
	movement_state_machine.initialize_for(self)
	control_state_machine.initialize_for(self)
	
	if is_locally_controlled:
		control_state_machine.change_state(local_controlled_state)
		movement_state_machine.change_state(free_fall_state)

func _physics_process(delta):
	movement_state_machine.process_physics(delta)
	control_state_machine.process_physics(delta)

func _process(delta):
	movement_state_machine.process_frame(delta)
	control_state_machine.process_frame(delta)

func _unhandled_input(event):
	movement_state_machine.process_input(event)
	control_state_machine.process_input(event)

func set_is_facing_left(is_facing_left: bool):
	sprite.flip_h = is_facing_left
