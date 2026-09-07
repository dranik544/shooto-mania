# player.gd
extends KinematicBody2D

onready var gui = $gui
onready var sprite = $Sprite

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")*2.5
var velocity: Vector2 = Vector2.ZERO

export var moveSpeed: float = 75.0
export var moveSpeedMod: float = 1.0
export var moveAcceleration: float = 800.0
export var moveFriction: float = 800.0
export var jumpForce: float = -90.0
export var health: float = 100.0
export var maxHealth: float = health

var dead: bool = false


func _process(delta):
	if !is_on_floor():
		sprite.rotation_degrees += (velocity.y if velocity.x < 0 else -velocity.y) * 2 * delta
	else:
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, 0, 20 * delta)

func _physics_process(delta: float) -> void:
	var input_direction: float = 0.0
	input_direction += 1.0 if Input.is_action_pressed("RIGHT") else 0.0
	input_direction -= 1.0 if Input.is_action_pressed("LEFT") else 0.0
	
	var targetMoveSpeed: float = moveSpeed
	targetMoveSpeed *= moveSpeedMod
	
	if input_direction != 0.0:
		  velocity.x = move_toward(velocity.x, input_direction * targetMoveSpeed, moveAcceleration * delta)
	else: velocity.x = move_toward(velocity.x, 0.0, moveFriction * delta)
	velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("JUMP") && is_on_floor():
		velocity.y = jumpForce * moveSpeedMod
	
	moveSpeedMod = clamp(
		moveSpeedMod + (
			(velocity.x + velocity.y) / 2 * 0.00001
			if velocity.length() > 4.5 else
			-0.2
		),
		1.0, 5.0
	)
	
	velocity = move_and_slide(velocity, Vector2.UP)


func change_health(damage: float):
	if dead: return
	
	health += damage

func kill():
	dead = true
	health = maxHealth
	
	hide()
	set_physics_process(false)
	
	gui.get_node("deathLabel").show()
	yield(get_tree().create_timer(5.0), "timeout")
	gui.get_node("deathLabel").hide()
	
	dead = false
	show()
	set_physics_process(true)
	
	global_position = get_tree().get_first_node_in_group("spawn point").take_random_spawn_point().global_position

func apply_recoil(force: Vector2, boostXforce: bool = true):
	if dead: return
	
	if boostXforce: force.x *= 1.5
	velocity += force
