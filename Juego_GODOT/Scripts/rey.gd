extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var area_ataque = $Area2D
@onready var hit = $sonidoHit
@onready var hachazo = $golpe
@onready var saltar = $saltar
@onready var morir = $morir
@onready var musica = $musicaFondo
@onready var recoger_moneda = $recolectar_moneda

@export var gravedad: float = 1200.0
@export var max_caida: float = 1000.0

const VELOCIDAD = 150.0
const IMPULSO_SALTO = -400.0
const GRAVEDAD_SUBIDA = 1200.0
const GRAVEDAD_BAJADA = 2000.0
const MULTIPLICADOR_SALTO_CORTO = 0.6
const MAX_VELOCIDAD_CAIDA = 1200.0
const IMPULSO_RETROCESO = 100.0
const IMPULSO_RETROCESO_DAÑO = 100.0
const COOLDOWN_ATAQUE = 0.2

var vida = 5
var invulnerable = false
var monedas = 0
var bloqueado = false
var recibiendo_daño := false
var muerto = false
var en_secuencia_puerta = false
var puede_atacar = true
var atacando = false
var estaba_en_el_aire = false
var aterrizo_recientemente = false
var direccion_movimiento = 0

func _physics_process(delta):
	if bloqueado or muerto:
		return
	if en_secuencia_puerta:
		move_and_slide()
		return
	_aplicar_gravedad(delta)
	_detectar_aterrizaje()

	if not atacando:
		direccion_movimiento = Input.get_axis("move_left", "move_right")
		_aplicar_movimiento_horizontal()

	if Input.is_action_just_pressed("jump") and is_on_floor() and not atacando and not aterrizo_recientemente:
		saltar.play()
		velocity.y = IMPULSO_SALTO
		anim.play("jump")

	if Input.is_action_just_released("jump") and velocity.y < 0 and not aterrizo_recientemente:
		velocity.y *= 0.5

	if Input.is_action_just_pressed("attack") and puede_atacar and not muerto:
		_atacar()

	_actualizar_animacion()
	move_and_slide()
	area_ataque.position.x = -21 if anim.flip_h else 21

func _aplicar_gravedad(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
		velocity.y = min(velocity.y, max_caida)
	else:
		velocity.y = 0

func _detectar_aterrizaje():
	if not is_on_floor():
		estaba_en_el_aire = true
	else:
		if estaba_en_el_aire and not aterrizo_recientemente and not atacando:
			_reproducir_aterrizaje()
		estaba_en_el_aire = false

func _aplicar_movimiento_horizontal():
	if direccion_movimiento != 0:
		velocity.x = direccion_movimiento * VELOCIDAD
		anim.flip_h = direccion_movimiento < 0
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD * 3 * get_physics_process_delta_time())

func _actualizar_animacion():
	if atacando or aterrizo_recientemente:
		return
	if not is_on_floor():
		anim.play("jump" if velocity.y < 0 else "fall")
	elif direccion_movimiento != 0:
		anim.play("run")
	else:
		anim.play("idle")

func agregar_moneda(cantidad: int):
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.añadir_moneda(1)
	recoger_moneda.play()
	monedas += cantidad

func recibir_dano(cantidad: int = 1):
	if muerto or invulnerable:
		return
	recibiendo_daño = true
	invulnerable = true
	atacando = true
	anim.play("hit")

	vida -= cantidad

	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("actualizar_vida"):
		hud.call_deferred("actualizar_vida", vida)

	if vida <= 0:
		_morir()
		return

	hit.play()
	var dir = 1 if anim.flip_h else -1
	velocity = Vector2(dir * IMPULSO_RETROCESO_DAÑO, -100)

	for i in range(10):
		move_and_slide()
		await get_tree().process_frame

	velocity = Vector2.ZERO
	await anim.animation_finished
	atacando = false
	invulnerable = false
	recibiendo_daño = false
	await get_tree().create_timer(1.0).timeout

func _morir():
	musica.stop()
	morir.play()
	muerto = true
	anim.play("dead")
	velocity.x = 0
	Global.score_nivel1 = 0
	Global.score_nivel2 = 0
	Global.score_nivel3 = 0
	var death = get_tree().get_first_node_in_group("death_screen")
	if death: death.mostrar_pantalla_muerte()
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.actualizar_muertes()

func _atacar():
	if recibiendo_daño:
		return
	atacando = true
	puede_atacar = false
	anim.play("attack")
	hachazo.play()
	velocity = Vector2.ZERO
	area_ataque.set_deferred("monitoring", true)
	area_ataque.set_deferred("monitorable", true)
	await get_tree().create_timer(0.1).timeout
	var cuerpos = area_ataque.get_overlapping_bodies()

	if cuerpos.size() > 0:
		var golpeo_enemigo = false
		for cuerpo in cuerpos:
			if cuerpo != self and cuerpo.has_method("recibir_dano"):
				cuerpo.recibir_dano(1)
				_aplicar_retroceso()
				golpeo_enemigo = true
				break
		if not golpeo_enemigo:
			_aplicar_retroceso()

	area_ataque.monitoring = false
	area_ataque.monitorable = false
	await anim.animation_finished
	atacando = false
	await get_tree().create_timer(COOLDOWN_ATAQUE).timeout
	puede_atacar = true

func _reproducir_aterrizaje():
	aterrizo_recientemente = true
	anim.play("ground")
	await anim.animation_finished
	aterrizo_recientemente = false

func _aplicar_retroceso():
	var direccion = -1 if anim.flip_h else 1
	velocity.x = direccion * -IMPULSO_RETROCESO

func _ready():
	add_to_group("player")
	if GameManager.partida.size() > 0 and not GameManager.carga_aplicada:
		global_position = Vector2(
			GameManager.partida.get("pos_x", global_position.x),
			GameManager.partida.get("pos_y", global_position.y)
		)
		GameManager.carga_aplicada = true

	musica.play()
	en_secuencia_puerta = true
	anim.play("door_out")
	await anim.animation_finished
	en_secuencia_puerta = false
