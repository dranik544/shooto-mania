# deathZone.gd
extends Area2D


func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node2D):
	if body.has_method("kill"): body.kill(); print("kill")
