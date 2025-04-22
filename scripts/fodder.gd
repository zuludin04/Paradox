extends CharacterBody2D

@export var BulletScene : PackedScene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_shooting = false
var player = null

func _physics_process(delta: float) -> void:
	handle_animation()
	move_and_slide()

func _on_shooting_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		$ShootingTimer.start()

func _on_shooting_timer_timeout() -> void:
	if player != null && !player.is_dead:
		is_shooting = true
		shoot()

func _on_shooting_area_body_exited(body: Node2D) -> void:
	is_shooting = false
	$ShootingTimer.stop()

func _on_shooting_area_area_exited(area: Area2D) -> void:
	if area == Global.playerHitArea:
		is_shooting = false
		
func shoot():
	var bullet = BulletScene.instantiate()
	owner.add_child(bullet)
	bullet.transform = $BulletSpawn.global_transform
	
	$ShootingTimer.start()
	
func handle_animation():
	if is_shooting:
		animated_sprite.play("shoot")
	else:
		animated_sprite.play("idle")
