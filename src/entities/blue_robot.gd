extends CharacterBody2D

const MAX_SPEED: float = 2000
const ACCELERATION: float = FRICTION + 500
const JUMP_SPEED: float = 1000.0
const DASH_MAX_SPEED: float = 3000
const DASH_CHARGE_RATE: float = 0.50
const FRICTION: float = 2000.0
const RIGHT_DASH_DIRECTION: Vector2 = Vector2(4,-1)
const LEFT_DASH_DIRECTION: Vector2 = Vector2(-4, -1)
const MULTIPLAYER_POSITION_LERP_WEIGHT: float = 0.7

const robot_type: GameManager.RobotType = GameManager.RobotType.BLUE
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping: bool = false
var dash_charge: float = 0.0
var is_locally_controlled: bool = false
var player_name: String
var synced_global_position: Vector2 = self.global_position

func _physics_process(delta):
	print(velocity.x)
	# Add the gravity.
	if not is_locally_controlled:
		global_position = global_position.lerp(synced_global_position, \
			MULTIPLAYER_POSITION_LERP_WEIGHT)
		return

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = - JUMP_SPEED
			is_jumping = true
		else:
			is_jumping =  false
			
			var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			
			if Input.is_action_pressed("dash"):
				if dash_charge < 1.0:
					dash_charge += DASH_CHARGE_RATE * delta
			elif dash_charge > 0.0:
					velocity = dash_charge * DASH_MAX_SPEED * direction
					dash_charge = 0
			elif direction.x != 0 and absf(velocity.x) < MAX_SPEED:
					velocity.x += ACCELERATION * delta * direction.x
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		dash_charge = 0.0
		if is_jumping:
			if not (velocity.y < 0 and Input.is_action_pressed("jump")):
				velocity.y *= 0.6 # to suddenly halt jumping without much of a visible jerk
				is_jumping = false
		
		velocity.y += gravity * delta

	move_and_slide()
	synced_global_position = self.global_position
