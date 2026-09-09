# player.gd
extends KinematicBody2D

onready var gui = $gui
onready var sprite = $Sprite
onready var nickname_label = $nicknameLabel
onready var health_label = $healthLabel
onready var rpc_timer = $rpcTimer

var nickname: String

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


func _ready():
	set_network_master(name.to_int())
	
#	rpc_timer.connect("timeout", self, "_on_rpc_timer_timeout")
#	rpc_timer.start()

func _process(delta):
	if !is_network_master(): return
	
	if !is_on_floor():
		sprite.rotation_degrees += (velocity.y if velocity.x < 0 else -velocity.y) * 2 * delta
	else:
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, 0, 20 * delta)

func _physics_process(delta: float) -> void:
	if !is_network_master(): return
	
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
	
	rpc("sync_global_position", global_position)
	rpc("sync_sprite_rotation", sprite.rotation_degrees)

func _input(event):
	if event.is_action_pressed("KILL") && is_network_master(): rpc("kill")

func _on_rpc_timer_timeout():
	pass



func change_health(damage: float):
	if dead: return
	
	health += damage
	rpc("sync_health", health)
	
	if health <= 0: rpc("kill")

remotesync func kill():
	dead = true
	health = maxHealth
	
	visible = not dead
	set_physics_process(not dead)
	set_collision_layer_bit(4, false)
	set_collision_mask_bit(4, false)
	
	if is_network_master(): gui.get_node("deathLabel").show()
	yield(get_tree().create_timer(5.0), "timeout")
	if is_network_master(): gui.get_node("deathLabel").hide()
	
	dead = false
	
	visible = not dead
	set_physics_process(not dead)
	set_collision_layer_bit(4, true)
	set_collision_mask_bit(4, true)
	rpc("sync_health", health)
	
	global_position = get_tree().get_first_node_in_group("spawn point").take_random_spawn_point().global_position

func apply_recoil(force: Vector2, boostXforce: bool = true):
	if dead: return
	
	if boostXforce: force.x *= 1.5
	velocity += force

func apply_skin(skinIND: int = 0):
	if Global.allSkins.size() == 0:
		return
	var idx = skinIND % Global.allSkins.size()
	sprite.texture = load(Global.allSkins[idx])



remote func sync_global_position(globalPosition):
	global_position = globalPosition
remote func sync_sprite_rotation(sRotation):
	sprite.rotation_degrees = sRotation
remotesync func sync_health(sHealth: float):
	health = sHealth
	health_label.text = str(sHealth) + "/" + str(maxHealth) + " HP"

func set_nickname(new_name: String):
	nickname = new_name
	if nickname_label: nickname_label.text = nickname
