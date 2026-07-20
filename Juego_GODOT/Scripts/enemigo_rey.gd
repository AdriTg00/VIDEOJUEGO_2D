## enemigo_rey — Boss enemy with chase, attack area, and dialogue

extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var detector_area = $Area2D
@onready var grunt = $"gruñido_cerdo"
@onready var attack_area = $attackArea
@onready var dialog = $dialogo

@export var collision_margin: float = 20.0
@export var speed: float = 30.0
@export var gravity: float = 1200.0
@export var max_fall: float = 1000.0
@export var chase_range: float = 250.0

@export var jump_enabled := true
@export var cliff_distance := 24.0
@export var wall_distance := 20.0
@export var ground_ray_height := 32.0
@export var debug_rays := false

var player: CharacterBody2D = null
var dead := false
var taking_damage := false
var direction := 1
var is_chasing := false
var invulnerable := false
var hp = 10
var speed_bonus := 0
var _jumping := false

const JUMP_IMPULSE = -400.0

var _cliff_ray: RayCast2D
var _wall_ray: RayCast2D


## Lifecycle
func _ready():
	_cliff_ray = RayCast2D.new()
	_cliff_ray.name = "BossCliffRay"
	_cliff_ray.enabled = true
	_cliff_ray.collision_mask = 1
	add_child(_cliff_ray)

	_wall_ray = RayCast2D.new()
	_wall_ray.name = "BossWallRay"
	_wall_ray.enabled = true
	_wall_ray.collision_mask = 1
	add_child(_wall_ray)

	detector_area.body_entered.connect(_on_player_entered)
	detector_area.body_exited.connect(_on_player_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)


## Physics
func _physics_process(delta):
	if dead:
		return

	_apply_gravity(delta)

	if taking_damage:
		move_and_slide()
		return

	_update_ray_directions()

	if is_chasing and player:
		_chase_player()
	else:
		velocity.x = 0

	if is_on_floor() and _should_jump():
		_jump()

	move_and_slide()


func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall)
	else:
		velocity.y = 0
		_jumping = false


func _get_facing_dir() -> int:
	return 1 if anim.flip_h else -1


func _update_ray_directions():
	var dir = _get_facing_dir()
	_cliff_ray.target_position = Vector2(dir * cliff_distance, ground_ray_height)
	_wall_ray.target_position = Vector2(dir * wall_distance, -4)
	_cliff_ray.force_raycast_update()
	_wall_ray.force_raycast_update()
	if debug_rays:
		queue_redraw()


func _draw():
	if not debug_rays:
		return
	var dir = _get_facing_dir()
	var cliff_end = _cliff_ray.target_position
	var wall_end = _wall_ray.target_position
	if dir < 0 and cliff_end.x > 0:
		cliff_end.x *= -1
	if dir < 0 and wall_end.x > 0:
		wall_end.x *= -1
	var cliff_color = Color.YELLOW if not _cliff_ray.is_colliding() else Color.GREEN
	var wall_color = Color.RED if _wall_ray.is_colliding() else Color.GREEN
	draw_line(Vector2.ZERO, cliff_end, cliff_color, 1.0)
	draw_line(Vector2.ZERO, wall_end, wall_color, 1.0)


func _should_jump() -> bool:
	if not jump_enabled or _jumping:
		return false
	var col = _wall_ray.get_collider()
	if col and col.is_in_group("player"):
		return false
	return _wall_ray.is_colliding()


func _jump():
	_jumping = true
	velocity.y = JUMP_IMPULSE


## Chase player with increasing speed
func _chase_player():
	var dir = sign(player.global_position.x - global_position.x)
	if dir < 0:
		velocity.x = dir * speed - speed_bonus
	else:
		velocity.x = dir * speed + speed_bonus
	anim.flip_h = dir > 0
	anim.play("run")


## Handle damage with speed boost and dialogue trigger
func take_damage(amount: int = 1):
	speed_bonus += 10
	dialog.play("angry", 2.0)

	if dead or invulnerable:
		return
	taking_damage = true
	hp -= amount
	if hp <= 0:
		GameManager.end_game()
		_die()
		return
	invulnerable = true

	anim.play("hit")

	var knockback_dir = 0
	if player:
		knockback_dir = sign(global_position.x - player.global_position.x)
	else:
		knockback_dir = -direction

	velocity.x = knockback_dir * 50
	move_and_slide()
	await anim.animation_finished
	taking_damage = false
	invulnerable = false


## Death sequence
func _die():
	dead = true
	is_chasing = false
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.add_coin(3)
	velocity = Vector2.ZERO
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	anim.play("dead")
	await anim.animation_finished
	queue_free()
	var win = get_tree().get_first_node_in_group("win_screen")
	if win: win.show_win_screen()


func _on_player_entered(body):
	if body.name == "Rey":
		grunt.play()
		player = body
		is_chasing = true


func _on_player_exited(body):
	if taking_damage:
		return
	if body == player:
		player = null
		is_chasing = false


## Attack player on contact
func _on_attack_area_body_entered(body: Node2D) -> void:
	if not body or not body.has_method("take_damage"):
		return
	if body.is_inside_tree():
		is_chasing = false
		velocity.x = 0
		anim.play("attack")
		body.take_damage(1)
		await anim.animation_finished
		anim.play("idle")
		await get_tree().create_timer(1.0).timeout
		is_chasing = true
