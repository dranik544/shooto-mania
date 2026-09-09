# global.gd
extends Node

var ver: String = "ver1t6"


var bulletScenes: Dictionary = {
	"base_bullet": preload("res://scenes/bullets/base_bullet.tscn"),
	"bullet_dick": preload("res://scenes/bullets/bullet_dick.tscn"),
	"bullet_shotgun": preload("res://scenes/bullets/bullet_shotgun.tscn"),
}
var bulletPool: Dictionary = {}
var defaultPoolBulletSize: int = 20
var allSkins: Array = [
	"res://sprites/player/player1.png",
	"res://sprites/player/player2.png",
	"res://sprites/player/player3.png",
	"res://sprites/player/player4.png",
	"res://sprites/player/player5.png",
	"res://sprites/player/player6.png",
	"res://sprites/player/player7.png",
	"res://sprites/player/player8.png",
	"res://sprites/player/player9.png",
	"res://sprites/player/player10.png",
	"res://sprites/player/player11.png",
	"res://sprites/player/player12.png",
	"res://sprites/player/player13.png",
	
	"res://sprites/player/slug_player.png",
]


func add_type_bullets_to_pool(type: String):
	if !bulletScenes.has(type): return
	if !bulletPool.has(type): bulletPool[type] = []
	
	for i in defaultPoolBulletSize: create_new_bullet(type)

func add_bullet_to_pool(bullet):
	bullet.hide()
	bullet.global_position = Vector2(-10000.0, -10000.0)
	
	bulletPool[bullet.type].append(bullet)

func take_bullet_from_pool(type: String):
	if !bulletPool.has(type): bulletPool[type] = []
	
	var bullet
	if !bulletPool[type].empty():
		bullet = bulletPool[type].pop_back()
	else:
		bullet = create_new_bullet(type)
	
	return bullet

func create_new_bullet(type):
	if !bulletScenes.has(type): return null
	
	var bullet = bulletScenes[type].instance()
	get_tree().current_scene.add_child(bullet)
	bulletPool[type].append(bullet)
	
	return bullet
