# base_weapon.gd
extends Node2D

onready var sprite = $Sprite
onready var timer = $Timer

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

func _physics_process(delta):
	rotation = (get_global_mouse_position() - global_position).angle()
	
	if Input.is_action_pressed("FIRE"):
		fire()

func _on_timer_timeout():
	canFire = true


func fire():
	if canFire:
		var bullet = Global.take_bullet_from_pool(bulletType)
		
		var direction: Vector2 = get_global_mouse_position() - global_position
		bullet.global_position = global_position + Vector2(8.0, 0.0).rotated(rotation)
		bullet.direction = direction.normalized()
		bullet.player = get_parent()
		
		bullet.activate()
		
		if get_parent(): get_parent().apply_recoil(-direction * recoilForce)
		
		canFire = false
		timer.start()
