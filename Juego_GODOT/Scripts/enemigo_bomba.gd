## enemigo_bomba — Bomb-throwing enemy

extends CharacterBody2D

@export var bomb_scene: PackedScene
@onready var anim = $AnimatedSprite2D
@onready var timer = $Timer
@onready var detector = $Area2D
@export var gravity: float = 1200.0
@export var max_fall: float = 1000.0

var player_detected = false
var throwing := false
var taking_damage := false
var invulnerable := false
var hp = 5
var dead := false
var player: CharacterBody2D


## Lifecycle
func _ready():
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)


## Physics
func _physics_process(delta):
	if taking_damage:
		return
	if player_detected and player:
		if player.global_position.x > global_position.x:
			anim.flip_h = true
		else:
			anim.flip_h = false
	_apply_gravity(delta)
	move_and_slide()


func _on_body_entered(body):
	if body.name == "Rey":
		print('entro')
		player = body
		player_detected = true
		_start_throwing()


func _on_body_exited(body):
	if body.name == "Rey":
		print('salió')
		player = null
		player_detected = false
		throwing = false
		timer.stop()
		anim.play("idle")


func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall)
	else:
		velocity.y = 0


func _on_timer_timeout():
	if player_detected:
		_start_throwing()


func take_damage(amount: int = 1):
	if dead or invulnerable:
		return
	taking_damage = true
	invulnerable = true
	hp -= amount
	print("El cerdo recibió daño. Vida restante:", hp)

	if hp <= 0:
		_die()
		return

	anim.play("hit")
	await anim.animation_finished
	taking_damage = false
	invulnerable = false


## Death sequence
func _die():
	dead = true
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.add_coin(3)
	print("El cerdo ha muerto")
	velocity = Vector2.ZERO
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	anim.play("dead")
	await anim.animation_finished
	queue_free()


## Throw bomb toward player direction
func _start_throwing():
	if taking_damage:
		return
	if not throwing and player_detected:
		throwing = true
		anim.play("throwing")
		await anim.animation_finished
		anim.play("idle")
		var bomba = bomb_scene.instantiate()
		get_tree().current_scene.add_child(bomba)
		if player.global_position.x > global_position.x:
			bomba.global_position = global_position + Vector2(15, -15)
			bomba.apply_impulse(Vector2(150, -170))
		else:
			bomba.global_position = global_position + Vector2(-15, -5)
			bomba.apply_impulse(Vector2(-170, -150))

		throwing = false
		timer.start(1.0)
