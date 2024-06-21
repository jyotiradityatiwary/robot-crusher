extends CharacterBody2D

@export var local_controlled_state: State
@export var free_fall_state: State
@export var robot_type: GameManager.RobotType = GameManager.RobotType.BLUE

var is_locally_controlled: bool = false
var player_name: String
var synced_global_position: Vector2 = self.global_position

@onready var movement_state_machine: StateMachine = $MovementStateMachine
@onready var control_state_machine: StateMachine = $ControlStateMachine

func _ready():
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
