extends CharacterBody2D

class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_area: Area2D = $HitArea

var health = 50
var is_dead = false

func _ready() -> void:
	Global.player = self
	Global.playerHitArea = hit_area

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if !is_dead:
		handle_player_movement()
	move_and_slide()

func _on_hit_area_area_entered(area: Area2D) -> void:
	if area is Bullet:
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

func deal_damage():
	if !is_dead:
		health -= 10
		animated_sprite.play("hurt")
		await get_tree().create_timer(1.0).timeout
		animated_sprite.play("idle")
		if health == 0:
			is_dead = true
			animated_sprite.play("dead")
			hit_area.queue_free()
