# camera2d.gd
extends Camera2D

onready var player = get_parent()

export var baseZoom: Vector2 = zoom


func _process(delta: float) -> void:
	zoom = lerp(zoom, baseZoom + Vector2(player.velocity.length(), player.velocity.length())*0.0001, 10 * delta)
