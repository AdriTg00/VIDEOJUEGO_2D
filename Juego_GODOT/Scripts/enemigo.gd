## enemigo.gd — Base enemy with patrol, chase, jump, and damage

extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var detector_area = $Area2D
@onready var gruñido = $"gruñido_cerdo"

@export var margen_colision: float = 20.0
@export var velocidad: float = 50.0
@export var gravedad: float = 1200.0
@export var max_caida: float = 1000.0
@export var rango_persecucion: float = 250.0
@export var tiempo_idle_colision: float = 1.0

@export var salto_habilitado := true
@export var dist_precipicio := 20.0
@export var dist_pared := 16.0
@export var altura_rayo_suelo := 28.0
@export var debug_rayos := false

var jugador: CharacterBody2D = null
var muerto := false
var recibiendo_daño := false
var direccion := 1
var en_persecucion := false
var patrullando := false
var cancelando_patruya := false
var en_pausa_colision := false
var invulnerable := false
var vida = 5
var _saltando := false

const IMPULSO_SALTO = -400.0

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

	detector_area.body_entered.connect(_on_jugador_entro)
	detector_area.body_exited.connect(_on_jugador_salio)
	_iniciar_patruya()


## Physics
func _physics_process(delta):
	if muerto:
		return
	_aplicar_gravedad(delta)

	if recibiendo_daño:
		move_and_slide()
		return

	_actualizar_dir_rayos()

	if en_persecucion and jugador and not en_pausa_colision:
		_perseguir_jugador()
	elif not patrullando and not en_pausa_colision:
		_iniciar_patruya()

	if is_on_floor() and _debe_saltar():
		_saltar()

	move_and_slide()

func _aplicar_gravedad(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
		velocity.y = min(velocity.y, max_caida)
	else:
		velocity.y = 0
		_saltando = false

func _get_facing_dir() -> int:
	return 1 if anim.flip_h else -1

func _actualizar_dir_rayos():
	var dir = _get_facing_dir()
	_cliff_ray.target_position = Vector2(dir * dist_precipicio, altura_rayo_suelo)
	_wall_ray.target_position = Vector2(dir * dist_pared, -4)
	_cliff_ray.force_raycast_update()
	_wall_ray.force_raycast_update()
	if debug_rayos:
		queue_redraw()

func _draw():
	if not debug_rayos:
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

func _debe_saltar() -> bool:
	if not salto_habilitado or _saltando:
		return false
	var col = _wall_ray.get_collider()
	if col and col.is_in_group("player"):
		return false
	return _wall_ray.is_colliding()

func _saltar():
	_saltando = true
	velocity.y = IMPULSO_SALTO
	anim.play("jump")


## Chase player within range
func _perseguir_jugador():
	var dist = global_position.distance_to(jugador.global_position)
	if dist > rango_persecucion:
		en_persecucion = false
		_iniciar_patruya()
		return

	var dir = sign(jugador.global_position.x - global_position.x)
	velocity.x = dir * velocidad
	anim.flip_h = dir > 0
	anim.play("run")

	if _colisiona_con_jugador():
		if recibiendo_daño:
			return
		if jugador and jugador.has_method("recibir_dano"):
			jugador.recibir_dano(1)
		await _pausa_idle_colision()

func _colisiona_con_jugador() -> bool:
	if jugador:
		var dx = abs(global_position.x - jugador.global_position.x)
		var dy = abs(global_position.y - jugador.global_position.y)
		return dx < margen_colision and dy < margen_colision
	return false

func _pausa_idle_colision():
	if recibiendo_daño:
		return
	en_pausa_colision = true
	velocity.x = 0
	await get_tree().create_timer(tiempo_idle_colision).timeout
	en_pausa_colision = false

func _iniciar_patruya():
	gruñido.stop()
	patrullando = true
	_patrol_loop()


## Handle damage with hit animation and knockback
func recibir_dano(cantidad: int = 1):
	if muerto or invulnerable:
		return
	recibiendo_daño = true
	vida -= cantidad
	if vida <= 0:
		_morir()
		return
	invulnerable = true
	anim.play("hit")
	var dir_retroceso = sign(global_position.x - jugador.global_position.x)
	velocity.x = dir_retroceso * 50
	move_and_slide()
	await anim.animation_finished
	en_persecucion = true
	recibiendo_daño = false
	invulnerable = false


## Patrol back and forth
func _patrol_loop():
	await get_tree().process_frame
	while not muerto and not en_persecucion:
		anim.play("run")
		velocity.x = direccion * velocidad
		anim.flip_h = direccion > 0
		await get_tree().create_timer(1.0).timeout
		anim.play("idle")
		velocity.x = 0
		await get_tree().create_timer(2.0).timeout
		direccion *= -1
	patrullando = false


## Death sequence
func _morir():
	muerto = true
	en_persecucion = false
	patrullando = false
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.añadir_moneda(3)
	velocity = Vector2.ZERO
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	anim.play("dead")
	await anim.animation_finished
	queue_free()

func _on_jugador_entro(cuerpo):
	if cuerpo.name == "Rey":
		gruñido.play()
		jugador = cuerpo
		en_persecucion = true

func _on_jugador_salio(cuerpo):
	if recibiendo_daño:
		return
	if cuerpo == jugador:
		jugador = null
		en_persecucion = false