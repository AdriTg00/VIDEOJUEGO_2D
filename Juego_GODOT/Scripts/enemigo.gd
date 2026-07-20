## enemigo — Base enemy with patrol, chase, jump, and damage

extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var detector_area = $Area2D
@onready var grunt = $"gruñido_cerdo"

@export var collision_margin: float = 20.0
@export var speed: float = 50.0
@export var gravity: float = 1200.0
@export var max_fall: float = 1000.0
@export var chase_range: float = 250.0
@export var collision_idle_time: float = 1.0

@export var jump_enabled := true
@export var cliff_distance := 20.0
@export var wall_distance := 16.0
@export var ground_ray_height := 28.0
@export var debug_rays := false

var player: CharacterBody2D = null
var dead := false
var taking_damage := false
var direction := 1
var is_chasing := false
var is_patrolling := false
var cancel_patrol := false
var collision_paused := false
var invulnerable := false
var hp = 5
var _jumping := false

const JUMP_IMPULSE = -400.0

var _cliff_ray: RayCast2D
var _wall_ray: RayCast2D


## Lifecycle
func _ready():
	_cliff_ray = RayCast2D.new()
	_cliff_ray.name = "CliffRay"
	_cliff_ray.enabled = true
	_cliff_ray.collision_mask = 1
	add_child(_cliff_ray)

	_wall_ray = RayCast2D.new()
	_wall_ray.name = "WallRay"
	_wall_ray.enabled = true
	_wall_ray.collision_mask = 1
	add_child(_wall_ray)

	detector_area.body_entered.connect(_on_player_entered)
	detector_area.body_exited.connect(_on_player_exited)
	_start_patrol()


## Physics
func _physics_process(delta):
	if dead:
		return
	_apply_gravity(delta)

	if taking_damage:
		move_and_slide()
		return

	_update_ray_directions()

	if is_chasing and player and not collision_paused:
		_chase_player()
	elif not is_patrolling and not collision_paused:
		_start_patrol()

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
	anim.play("jump")


## Chase player within range
func _chase_player():
	var dist = global_position.distance_to(player.global_position)
	if dist > chase_range:
		is_chasing = false
		_start_patrol()
		return

	var dir = sign(player.global_position.x - global_position.x)
	velocity.x = dir * speed
	anim.flip_h = dir > 0
	anim.play("run")

	if _collides_with_player():
		if taking_damage:
			return
		if player and player.has_method("take_damage"):
			player.take_damage(1)
		await _pause_collision_idle()


func _collides_with_player() -> bool:
	if player:
		var dx = abs(global_position.x - player.global_position.x)
		var dy = abs(global_position.y - player.global_position.y)
		return dx < collision_margin and dy < collision_margin
	return false


func _pause_collision_idle():
	if taking_damage:
		return
	collision_paused = true
	velocity.x = 0
	await get_tree().create_timer(collision_idle_time).timeout
	collision_paused = false


func _start_patrol():
	grunt.stop()
	is_patrolling = true
	_patrol_loop()


## Handle damage with hit animation and knockback
func take_damage(amount: int = 1):
	if dead or invulnerable:
		return
	taking_damage = true
	hp -= amount
	if hp <= 0:
		_die()
		return
	invulnerable = true
	anim.play("hit")
	var dir_retroceso = sign(global_position.x - player.global_position.x)
	velocity.x = dir_retroceso * 50
	move_and_slide()
	await anim.animation_finished
	is_chasing = true
	taking_damage = false
	invulnerable = false


## Patrol back and forth
func _patrol_loop():
	await get_tree().process_frame
	while not dead and not is_chasing:
		anim.play("run")
		velocity.x = direction * speed
		anim.flip_h = direction > 0
		await get_tree().create_timer(1.0).timeout
		anim.play("idle")
		velocity.x = 0
		await get_tree().create_timer(2.0).timeout
		direction *= -1
	is_patrolling = false


## Death sequence
func _die():
	dead = true
	is_chasing = false
	is_patrolling = false
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.add_coin(3)
	velocity = Vector2.ZERO
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	anim.play("dead")
	await anim.animation_finished
	queue_free()


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
