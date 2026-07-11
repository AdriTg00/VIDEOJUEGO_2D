## enemigo_rey.gd — Boss enemy with chase, attack area, and dialogue

extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var detector_area = $Area2D
@onready var gruñido = $"gruñido_cerdo"
@onready var area_ataque = $attackArea
@onready var dialogo = $dialogo

@export var margen_colision: float = 20.0
@export var velocidad: float = 30.0
@export var gravedad: float = 1200.0
@export var max_caida: float = 1000.0
@export var rango_persecucion: float = 250.0

@export var salto_habilitado := true
@export var dist_precipicio := 24.0
@export var dist_pared := 20.0
@export var altura_rayo_suelo := 32.0
@export var debug_rayos := false

var jugador: CharacterBody2D = null
var muerto := false
var recibiendo_daño := false
var direccion := 1
var en_persecucion := false
var invulnerable := false
var vida = 10
var velocidad_sumar := 0
var _saltando := false

const IMPULSO_SALTO = -400.0

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

	detector_area.body_entered.connect(_on_jugador_entro)
	detector_area.body_exited.connect(_on_jugador_salio)
	area_ataque.body_entered.connect(_on_attack_area_body_entered)


## Physics
func _physics_process(delta):
	if muerto:
		return

	_aplicar_gravedad(delta)

	if recibiendo_daño:
		move_and_slide()
		return

	_actualizar_dir_rayos()

	if en_persecucion and jugador:
		_perseguir_jugador()
	else:
		velocity.x = 0

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


## Chase player with increasing speed
func _perseguir_jugador():
	var dir = sign(jugador.global_position.x - global_position.x)
	if dir < 0:
		velocity.x = dir * velocidad - velocidad_sumar
	else:
		velocity.x = dir * velocidad + velocidad_sumar
	anim.flip_h = dir > 0
	anim.play("run")


## Handle damage with speed boost and dialogue trigger
func recibir_dano(cantidad: int = 1):
	velocidad_sumar += 10
	dialogo.reproducir("angry", 2.0)

	if muerto or invulnerable:
		return
	recibiendo_daño = true
	vida -= cantidad
	if vida <= 0:
		GameManager.fin_de_juego()
		_morir()
		return
	invulnerable = true

	anim.play("hit")

	var dir_retroceso = 0
	if jugador:
		dir_retroceso = sign(global_position.x - jugador.global_position.x)
	else:
		dir_retroceso = -direccion

	velocity.x = dir_retroceso * 50
	move_and_slide()
	await anim.animation_finished
	recibiendo_daño = false
	invulnerable = false


## Death sequence
func _morir():
	muerto = true
	en_persecucion = false
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.añadir_moneda(3)
	velocity = Vector2.ZERO
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	anim.play("dead")
	await anim.animation_finished
	queue_free()
	var win = get_tree().get_first_node_in_group("win_screen")
	if win: win.mostrar_pantalla_ganador()

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


## Attack player on contact
func _on_attack_area_body_entered(body: Node2D) -> void:
	if not body or not body.has_method("recibir_dano"):
		return
	if body.is_inside_tree():
		en_persecucion = false
		velocity.x = 0
		anim.play("attack")
		body.recibir_dano(1)
		await anim.animation_finished
		anim.play("idle")
		await get_tree().create_timer(1.0).timeout
		en_persecucion = true