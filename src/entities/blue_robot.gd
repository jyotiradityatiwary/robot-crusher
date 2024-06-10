extends CharacterBody2D

const MAX_SPEED: float = 1000.0
const ACCELERATION: float = 5000.0
const JUMP_SPEED: float = 500.0
const MAX_JUMP_TIME: float = 0.8
const DASH_MAX_SPEED: float = MAX_SPEED * 4
const DASH_CHARGE_RATE: float = 0.50
const FRICTION: float = 2.0
const RIGHT_DASH_DIRECTION: Vector2 = Vector2(4,-1)
const LEFT_DASH_DIRECTION: Vector2 = Vector2(-4, -1)
const MULTIPLAYER_POSITION_LERP_WEIGHT: float = 0.7

const robot_type: GameManager.RobotType = GameManager.RobotType.BLUE
	# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_time: float = 0
var dash_charge: float = 0.0
var is_locally_controlled: bool = false
var player_name: String
var synced_global_position: Vector2 = self.global_position

func _physics_process(delta):
	# Add the gravity.
	if not is_locally_controlled:
		global_position = global_position.lerp(synced_global_position, \
			MULTIPLAYER_POSITION_LERP_WEIGHT)
		return

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = - JUMP_SPEED
			jump_time += delta
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
		dash_charge = 0
		if jump_time > 0 and jump_time < MAX_JUMP_TIME and Input.is_action_pressed("jump"):
			velocity.y = - JUMP_SPEED * (1 - jump_time / MAX_JUMP_TIME)
			jump_time += delta
			print("jump, v=", velocity.y, ", f=", jump_time/MAX_JUMP_TIME)
		else:
			jump_time = 0
			velocity.y += gravity * delta

	move_and_slide()
	synced_global_position = self.global_position
