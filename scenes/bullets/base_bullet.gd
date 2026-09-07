# bullet.gd
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
	if sprite.texture == null && texture != null: sprite.texture = texture
	timer.wait_time = lifeTime
	
	connect("body_entered", self, "_on_body_entered")
	timer.connect("timeout", self, "_on_timer_timeout")
	
	activate()

func _physics_process(delta):
	_bullet_process()

func _bullet_process():
	global_position += direction * speed

func _on_body_entered(body: Node2D):
	if !status: return
	_action_to_body(body)
	_after_body_entered()

func _on_timer_timeout():
	disable()
	Global.add_bullet_to_pool(self)


func _after_body_entered():
	if player: player.apply_recoil(-direction * recoilForce)
	disable()
	Global.add_bullet_to_pool(self)

func _action_to_body(body: Node2D):
	if body.has_method("change_health"): body.change_health(-damage)

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
