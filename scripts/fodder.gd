extends CharacterBody2D

@export var BulletScene: PackedScene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $ShootingArea/CollisionShape2D
@onready var bullet_spawn: Marker2D = $BulletSpawn
@onready var collision_attacked_shape: CollisionShape2D = $HitArea/CollisionShape2D
@onready var health_bar: ProgressBar = $HealthBar

var is_shooting = false
var player = null
var is_attacked = false
var is_dead = false

const dir = [Vector2.RIGHT, Vector2.LEFT]
const speed = 30

var health = 3
const damage_amount = 1

func _ready() -> void:
	Global.fodder = self
	health_bar.init_health(health)

func _process(delta: float) -> void:
	var p = Global.player
	if !p.is_dead && !is_attacked && !is_dead:
		var dir_to_player = position.direction_to(p.position) * speed
		velocity.x = dir_to_player.x
		var d = dir.front()
		animated_sprite.play("walk")
		d.x = abs(velocity.x) / velocity.x
		animated_sprite.flip_h = d.x == -1
		if velocity.x > 0:
			bullet_spawn.position.x = 14
		else:
			bullet_spawn.position.x = -14
	else:
		if !is_attacked and !is_dead:
			animated_sprite.play("idle")
		else:
			if is_attacked:
				animated_sprite.play("hurt")
		velocity.x = 0

func _physics_process(delta: float) -> void:
	if !is_attacked && !is_dead:
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

func _on_hit_area_area_entered(area: Area2D) -> void:
	var attack_area = Global.playerAttackArea
	if area == attack_area:
		take_damage()

func shoot():
	var bullet = BulletScene.instantiate()
	owner.add_child(bullet)
	bullet.transform = $BulletSpawn.global_transform
	
	$ShootingTimer.start()
	
func handle_animation():
	if is_shooting:
		animated_sprite.play("shoot")
	else:
		animated_sprite.play("walk")
		
func take_damage():
	if !is_dead:
		is_attacked = true
		health -= damage_amount
		health_bar.health = health
		animated_sprite.play("hurt")
		await get_tree().create_timer(1).timeout
		is_attacked = false
		print("health ", health)
		if health <= 0 && !is_dead:
			is_dead = true
			animated_sprite.play("dead")
			set_collision_layer_value(2, true)
			set_collision_layer_value(1, false)
			set_collision_mask_value(2, true)
			set_collision_mask_value(1, false)
