extends "res://scenes/weapons/base_weapon.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func fire():
	if canFire && !player.dead:
		var direction: Vector2 = get_global_mouse_position() - global_position
		for i in 5:
			var step = 30 / (5 - 1)
			var bullet = Global.take_bullet_from_pool(bulletType)
			bullet.global_position = global_position + Vector2(8.0, 0.0).rotated(rotation)
			bullet.direction = direction.rotated(deg2rad(-30/2 + i * step)).normalized()
			bullet.player = player
			
			bullet.activate()
		
		if player: player.apply_recoil(-direction * recoilForce)
		
		canFire = false
		timer.start()
