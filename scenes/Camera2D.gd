# camera2d.gd
extends Camera2D

onready var player = get_parent()

export var baseZoom: Vector2 = zoom


func _ready():
	for i in 3: yield(get_tree(), "idle_frame")
	
	if !player.is_network_master(): return
	current = true

func _process(delta: float) -> void:
	if !player.is_network_master(): return
	zoom = lerp(zoom, baseZoom + Vector2(player.velocity.length(), player.velocity.length())*0.0001, 10 * delta)
