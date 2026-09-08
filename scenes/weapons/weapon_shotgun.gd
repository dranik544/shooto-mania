extends "res://scenes/weapons/base_weapon.gd"


func fire():
	if canFire && !player.dead:
		if not is_network_master(): return
		
		var baseDirection: Vector2 = get_global_mouse_position() - global_position
		for i in 5:
			var step = 30 / (5 - 1)
			var bullet = Global.take_bullet_from_pool(bulletType)
			bullet.global_position = global_position + Vector2(8.0, 0.0).rotated(rotation)
			var direction: Vector2 = baseDirection.rotated(deg2rad(-30/2 + i * step)).normalized()
			bullet.direction = direction
			bullet.set_network_master(get_tree().get_network_unique_id())
			bullet.player = player
			
			bullet.activate()
			rpc("create_bullet_for_others", global_position, direction, bulletType, get_tree().get_network_unique_id())
		
		if player: player.apply_recoil(-baseDirection * recoilForce)
		
		canFire = false
		timer.start()
