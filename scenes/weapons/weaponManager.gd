# weaponManager.gd
extends Node2D

var weapons: Array = []
var currentWeapon: int = 0


func _ready():
	if weapons.empty(): for i in get_children(): weapons.append(i)
	
	apply_weapon(weapons[currentWeapon])

func _input(event):
	if event.is_action_pressed("PREV SELECT WEAPON") || event.is_action_pressed("NEXT SELECT WEAPON"):
		if event.is_action_pressed("PREV SELECT WEAPON"): currentWeapon -= 1
		if event.is_action_pressed("NEXT SELECT WEAPON"): currentWeapon += 1
		
		if currentWeapon < 0:                currentWeapon = weapons.size()-1
		if currentWeapon > weapons.size()-1: currentWeapon = 0
		
		apply_weapon(weapons[currentWeapon])

func apply_weapon(weapon):
	for i in weapons: i.disable()
	weapon.activate()
