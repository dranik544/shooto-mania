extends KinematicBody2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")*2.5
var velocity: Vector2 = Vector2.ZERO

export var moveSpeed: float = 60.0
export var moveAcceleration: float = 800.0
export var moveFriction: float = 800.0
export var jumpForce: float = -90.0


func _physics_process(delta: float) -> void:
	var input_direction: float = 0.0
	if Input.is_action_pressed("RIGHT"):
		input_direction += 1.0
	if Input.is_action_pressed("LEFT"):
		input_direction -= 1.0
	
	if input_direction != 0.0:
		  velocity.x = move_toward(velocity.x, input_direction * moveSpeed, moveAcceleration * delta)
	else: velocity.x = move_toward(velocity.x, 0.0, moveFriction * delta)
	velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("JUMP") and is_on_floor():
		velocity.y = jumpForce
	
	velocity = move_and_slide(velocity, Vector2.UP)
