extends Node2D


func _ready():
	add_to_group("spawn point")


func take_random_spawn_point():
	return get_children().pick_random()
