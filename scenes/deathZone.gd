# deathZone.gd
extends Area2D

onready var collision = $CollisionShape2D
onready var sprite = $Sprite



func _ready():
	connect("body_entered", self, "_on_body_entered")
	sprite.scale = collision.shape.extents*2
	sprite.global_position = collision.global_position

func _on_body_entered(body: Node2D):
	if body.has_method("kill"): body.kill(); print("kill")
