# main.gd
extends Node2D


func _ready():
	Global.add_type_bullets_to_pool("base_bullet")
	Global.add_type_bullets_to_pool("bullet_dick")
	Global.add_type_bullets_to_pool("bullet_shotgun")
	
	Network.on_game_scene_loaded()
	Network.inGame = true
