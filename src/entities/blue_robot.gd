extends CharacterBody2D

const MAX_SPEED: float = 1000.0
const ACCELERATION: float = 5000.0
const JUMP_MAX_SPEED: float = 1500.0
const JUMP_CHARGE_RATE: float = 0.50 # between 0 and 1
const DASH_MAX_SPEED: float = MAX_SPEED * 4
const DASH_CHARGE_RATE: float = 0.50
const FRICTION: float = 2.0
const RIGHT_DASH_DIRECTION: Vector2 = Vector2(4,-1)
const LEFT_DASH_DIRECTION: Vector2 = Vector2(-4, -1)

const robot_type: GameManager.RobotType = GameManager.RobotType.BLUE
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_charge: float = 0.0
var dash_charge: float = 0.0
var is_locally_controlled: bool = false
var player_name: String

func _physics_process(delta):
	# Add the gravity.
	if not is_locally_controlled:
		return

	if is_on_floor():
		if Input.is_action_pressed("jump"):
			if jump_charge < 1.0:
				jump_charge += JUMP_CHARGE_RATE * delta
		elif jump_charge > 0.0:
			velocity.y = - jump_charge * JUMP_MAX_SPEED
			jump_charge = 0
		else:
			#var direction = Input.get_axis("ui_left", "ui_right")
			var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			
			if Input.is_action_pressed("dash"):
				if dash_charge < 1.0:
					dash_charge += DASH_CHARGE_RATE * delta
			elif dash_charge > 0.0:
					velocity = dash_charge * DASH_MAX_SPEED * direction
					dash_charge = 0
			elif direction.x != 0:
					#velocity.x = direction.x * SPEED
					velocity.x = move_toward(velocity.x, MAX_SPEED * direction.x, ACCELERATION * delta)
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta * absf(velocity.x))
	else:
		velocity.y += gravity * delta
		jump_charge = 0
		dash_charge = 0
	
	move_and_slide()
