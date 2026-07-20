## rey — Player character controller

extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var area_ataque = $Area2D
@onready var hit = $sonidoHit
@onready var hachazo = $golpe
@onready var jump_sfx = $saltar
@onready var die_sfx = $morir
@onready var music = $musicaFondo
@onready var coin_sfx = $recolectar_moneda

@export var gravity: float = 1200.0
@export var max_fall: float = 1000.0

const SPEED = 150.0
const JUMP_IMPULSE = -400.0
const GRAVITY_UP = 1200.0
const GRAVITY_DOWN = 2000.0
const SHORT_JUMP_MULTIPLIER = 0.6
const MAX_FALL_SPEED = 1200.0
const KNOCKBACK_IMPULSE = 100.0
const DAMAGE_KNOCKBACK_IMPULSE = 100.0
const ATTACK_COOLDOWN = 0.2

var hp = 5
var invulnerable = false
var coins = 0
var locked = false
var taking_damage := false
var dead = false
var in_door_sequence = false
var can_attack = true
var attacking = false
var was_in_air = false
var landed_recently = false
var move_direction = 0


## Physics
func _physics_process(delta):
	if locked or dead:
		return
	if in_door_sequence:
		move_and_slide()
		return
	_apply_gravity(delta)
	_detect_landing()

	if not attacking:
		move_direction = Input.get_axis("move_left", "move_right")
		_apply_horizontal_movement()

	if Input.is_action_just_pressed("jump") and is_on_floor() and not attacking and not landed_recently:
		jump_sfx.play()
		velocity.y = JUMP_IMPULSE
		anim.play("jump")

	if Input.is_action_just_released("jump") and velocity.y < 0 and not landed_recently:
		velocity.y *= 0.5

	if Input.is_action_just_pressed("attack") and can_attack and not dead:
		_attack()

	_update_animation()
	move_and_slide()
	area_ataque.position.x = -21 if anim.flip_h else 21


func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall)
	else:
		velocity.y = 0


func _detect_landing():
	if not is_on_floor():
		was_in_air = true
	else:
		if was_in_air and not landed_recently and not attacking:
			_play_landing()
		was_in_air = false


func _apply_horizontal_movement():
	if move_direction != 0:
		velocity.x = move_direction * SPEED
		anim.flip_h = move_direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 20 * get_physics_process_delta_time())


func _update_animation():
	if attacking or landed_recently:
		return
	if not is_on_floor():
		anim.play("jump" if velocity.y < 0 else "fall")
	elif move_direction != 0:
		anim.play("run")
	else:
		anim.play("idle")


func add_coin(amount: int):
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.add_coin(1)
	coin_sfx.play()
	coins += amount


## Handle damage with invulnerability frames and knockback
func take_damage(amount: int = 1):
	if dead or invulnerable:
		return
	taking_damage = true
	invulnerable = true
	attacking = true
	anim.play("hit")

	hp -= amount

	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_health"):
		hud.call_deferred("update_health", hp)

	if hp <= 0:
		_die()
		return

	hit.play()
	var dir = 1 if anim.flip_h else -1
	velocity = Vector2(dir * DAMAGE_KNOCKBACK_IMPULSE, -100)

	for i in range(10):
		move_and_slide()
		await get_tree().process_frame

	velocity = Vector2.ZERO
	await anim.animation_finished
	attacking = false
	invulnerable = false
	taking_damage = false
	await get_tree().create_timer(1.0).timeout


## Death sequence
func _die():
	music.stop()
	die_sfx.play()
	dead = true
	anim.play("dead")
	velocity.x = 0
	Global.score_nivel1 = 0
	Global.score_nivel2 = 0
	Global.score_nivel3 = 0
	var death = get_tree().get_first_node_in_group("death_screen")
	if death: death.show_death_screen()
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.update_deaths()


## Attack with hit detection and cooldown
func _attack():
	if taking_damage:
		return
	attacking = true
	can_attack = false
	anim.play("attack")
	hachazo.play()
	velocity = Vector2.ZERO
	area_ataque.set_deferred("monitoring", true)
	area_ataque.set_deferred("monitorable", true)
	await get_tree().create_timer(0.1).timeout
	var bodies = area_ataque.get_overlapping_bodies()

	if bodies.size() > 0:
		var hit_enemy = false
		for body in bodies:
			if body != self and body.has_method("take_damage"):
				body.take_damage(1)
				_apply_knockback()
				hit_enemy = true
				break
		if not hit_enemy:
			_apply_knockback()

	area_ataque.monitoring = false
	area_ataque.monitorable = false
	await anim.animation_finished
	attacking = false
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true


func _play_landing():
	landed_recently = true
	anim.play("ground")
	await anim.animation_finished
	landed_recently = false


func _apply_knockback():
	var direction = -1 if anim.flip_h else 1
	velocity.x = direction * -KNOCKBACK_IMPULSE


## Lifecycle
func _ready():
	add_to_group("player")
	if GameManager.save_data.size() > 0 and not GameManager.load_applied:
		global_position = Vector2(
			GameManager.save_data.get("pos_x", global_position.x),
			GameManager.save_data.get("pos_y", global_position.y)
		)
		GameManager.load_applied = true

	music.play()
	in_door_sequence = true
	anim.play("door_out")
	await anim.animation_finished
	in_door_sequence = false
