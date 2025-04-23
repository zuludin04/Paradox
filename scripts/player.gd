extends CharacterBody2D

class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_area: Area2D = $HitArea
@onready var attack_area: Area2D = $AttackArea
@onready var collision_shape_attack: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var health_bar: ProgressBar = $CanvasLayer/HealthBar

var health = 50
var is_dead = false
var is_deal_damage = false
var is_attack = false

func _ready() -> void:
	Global.player = self
	Global.playerHitArea = hit_area
	Global.playerAttackArea = attack_area
	health_bar.init_health(health)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if !is_dead && !is_deal_damage:
		handle_player_movement()
	move_and_slide()

func _on_hit_area_area_entered(area: Area2D) -> void:
	if area is Bullet:
		is_deal_damage = true
		deal_damage()
		area.queue_free()

func handle_player_movement():
	if Input.is_action_just_pressed("top") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	collision_shape_attack.disabled = !is_attack
	handle_animation(direction)

func handle_animation(dir):
	if Input.is_action_just_pressed("attack"):
		is_attack = true
		animated_sprite.play("attack")
		await get_tree().create_timer(0.6).timeout
		is_attack = false
	elif is_on_floor() and !is_attack:
		if dir == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
			animated_sprite.flip_h = dir == -1
	elif !is_on_floor() and !is_attack:
		animated_sprite.play("jump")

func deal_damage():
	if !is_dead:
		health -= 10
		health_bar.health = health
		animated_sprite.play("hurt")
		await get_tree().create_timer(1.0).timeout
		if !is_dead:
			animated_sprite.play("idle")
			is_deal_damage = false
		if health <= 0 && !is_dead:
			is_dead = true
			is_deal_damage = true
			animated_sprite.play("dead")
			hit_area.queue_free()
