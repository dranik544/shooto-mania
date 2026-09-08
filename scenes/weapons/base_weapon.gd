# base_weapon.gd
extends Node2D

onready var sprite = $Sprite
onready var timer = $Timer
onready var player = get_parent().get_parent()

export(String) var type
export(String) var bulletType
export(StreamTexture) var texture
export(float) var reloadTime = 0.1
export(float) var recoilForce = 0.0

var canFire: bool = true


func _ready():
	if sprite.texture == null && texture != null: sprite.texture = texture
	
	timer.wait_time = reloadTime
	timer.connect("timeout", self, "_on_timer_timeout")
	
	set_physics_process(is_network_master())

func _physics_process(delta):
	if !is_network_master(): return
	
	rotation = (get_global_mouse_position() - global_position).angle()
	rpc("sync_rotation", rotation)
	
	if Input.is_action_pressed("FIRE"):
		fire()

func _on_timer_timeout():
	canFire = true


func fire():
	if canFire && !player.dead:
		if not is_network_master(): return
		
		var bullet = Global.take_bullet_from_pool(bulletType)
		
		var direction: Vector2 = (get_global_mouse_position() - global_position)
		bullet.global_position = global_position + Vector2(8.0, 0.0).rotated(rotation)
		bullet.direction = direction.normalized()
		bullet.set_network_master(get_tree().get_network_unique_id())
		bullet.player = player
		
		bullet.activate()
		rpc("create_bullet_for_others", global_position, direction.normalized(), bulletType, get_tree().get_network_unique_id())
		
		if player: player.apply_recoil(-direction * recoilForce)
		
		canFire = false
		timer.start()

remote func create_bullet_for_others(pos: Vector2, dir: Vector2, type: String, ownerID):
	if ownerID == get_tree().get_network_unique_id(): return
	
	var bullet = Global.take_bullet_from_pool(type)
	bullet.global_position = pos
	bullet.direction = dir
	bullet.player = get_tree().current_scene.get_node(str(ownerID))
	bullet.set_network_master(ownerID)
	bullet.activate()

func activate():
	set_physics_process(true)
	show()
	rpc("show")

func disable():
	set_physics_process(false)
	hide()
	rpc("hide")

remote func sync_rotation(sRotation):
	rotation = sRotation
