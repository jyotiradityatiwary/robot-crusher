extends CharacterBody2D


const MAX_SPEED: float = 500.0
const ACCELERATION: float = 500.0
const JUMP_MAX_SPEED: float = 1500.0
const JUMP_CHARGE_RATE: float = 0.50 # between 0 and 1
const DASH_MAX_SPEED: float = MAX_SPEED * 8
const DASH_CHARGE_RATE: float = 0.50
const FRICTION: float = 200.0
const RIGHT_DASH_DIRECTION: Vector2 = Vector2(4,-1)
const LEFT_DASH_DIRECTION: Vector2 = Vector2(-4, -1)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_charge = 0
var dash_charge = 0

func _physics_process(delta):
	# Add the gravity.
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
					print("Dash velocity = ", velocity)
					dash_charge = 0
			elif direction.x != 0:
					#velocity.x = direction.x * SPEED
					velocity.x = move_toward(velocity.x, MAX_SPEED * direction.x, ACCELERATION * delta)
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.y += gravity * delta
		jump_charge = 0
		dash_charge = 0
	
	move_and_slide()
