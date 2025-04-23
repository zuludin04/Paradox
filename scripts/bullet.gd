extends Area2D

class_name Bullet

var speed = 400
var fodder: CharacterBody2D

func _ready() -> void:
	Global.bullet = self
	fodder = Global.fodder

func _physics_process(delta: float) -> void:
	if fodder.velocity.x > 0:
		position += transform.x * speed * delta
	else:
		position -= transform.x * speed * delta
