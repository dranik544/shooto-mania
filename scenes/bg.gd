extends Node2D


func _process(delta):
	position += Vector2.ONE*4 * delta
	if position > Vector2.ONE*2: position = Vector2.ZERO
