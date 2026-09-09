extends Area2D

onready var sprite = $Sprite
onready var timer = $Timer
onready var player

export(String) var type
export(Vector2) var direction = Vector2.ZERO
export(float) var speed = 40.0
export(StreamTexture) var texture
export(float) var lifeTime = 5.0
export(float) var recoilForce = 0.0
export(float) var damage = 10.0

var status: bool = true

func _ready():
	if sprite.texture == null && texture != null:
		sprite.texture = texture
	timer.wait_time = lifeTime
	connect("body_entered", self, "_on_body_entered")
	timer.connect("timeout", self, "_on_timer_timeout")
	disable()

func _physics_process(delta):
	if !is_network_master(): return
	if !status: return
	global_position += direction * speed
	if get_tree().network_peer and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerENet.CONNECTION_CONNECTED:
		rpc_unreliable("sync_global_position", global_position)

func activate():
	status = true
	timer.start()
	set_physics_process(true)
	show()
	rotate(rand_range(0.0, 1.0))

func disable():
	status = false
	timer.stop()
	set_physics_process(false)
	global_position = Vector2(-10000.0, -10000.0)
	hide()

func _on_body_entered(body: Node2D):
	if !is_network_master(): return
	if !status: return
	
	if body.has_method("change_health"):
		body.change_health(-damage)
	if body.has_method("apply_recoil"):
		body.apply_recoil(-direction * recoilForce)
	rpc("remove_bullet")
	disable()
	Global.add_bullet_to_pool(self)

func _on_timer_timeout():
	if is_network_master():
		rpc("remove_bullet")
	disable()
	Global.add_bullet_to_pool(self)

remote func remove_bullet():
	disable()
	Global.add_bullet_to_pool(self)

remote func sync_global_position(sPosition):
	global_position = sPosition
