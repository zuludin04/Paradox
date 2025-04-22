extends Area2D

class_name Bullet

var speed = 400

func _ready() -> void:
	Global.bullet = self

func _physics_process(delta: float) -> void:
	position -= transform.x * speed * delta
