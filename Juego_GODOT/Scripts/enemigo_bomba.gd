## enemigo_bomba.gd — Bomb-throwing enemy

extends CharacterBody2D

@export var bomba_scene: PackedScene
@onready var anim = $AnimatedSprite2D
@onready var timer = $Timer
@onready var detector = $Area2D
@export var gravedad: float = 1200.0
@export var max_caida: float = 1000.0

var jugador_detectado = false
var lanzando := false
var recibiendo_daño := false
var invulnerable := false
var vida = 5
var muerto := false
var jugador: CharacterBody2D


## Lifecycle
func _ready():
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)


## Physics
func _physics_process(delta):
	if recibiendo_daño:
		return
	if jugador_detectado and jugador:
		if jugador.global_position.x > global_position.x:
			anim.flip_h = true
		else:
			anim.flip_h = false
	_aplicar_gravedad(delta)
	move_and_slide()

func _on_body_entered(body):
	if body.name == "Rey":
		print('entro')
		jugador = body
		jugador_detectado = true
		_iniciar_lanzamiento()

func _on_body_exited(body):
	if body.name == "Rey":
		print('salió')
		jugador = null
		jugador_detectado = false
		lanzando = false
		timer.stop()
		anim.play("idle")

func _aplicar_gravedad(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
		velocity.y = min(velocity.y, max_caida)
	else:
		velocity.y = 0

func _on_timer_timeout():
	if jugador_detectado:
		_iniciar_lanzamiento()

func recibir_dano(cantidad: int = 1):
	if muerto or invulnerable:
		return
	recibiendo_daño = true
	invulnerable = true
	vida -= cantidad
	print("El cerdo recibió daño. Vida restante:", vida)

	if vida <= 0:
		_morir()
		return

	anim.play("hit")
	await anim.animation_finished
	recibiendo_daño = false
	invulnerable = false


## Death sequence
func _morir():
	muerto = true
	var hud = get_tree().get_first_node_in_group("hud")
	if hud: hud.añadir_moneda(3)
	print("El cerdo ha muerto")
	velocity = Vector2.ZERO
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	anim.play("dead")
	await anim.animation_finished
	queue_free()


## Throw bomb toward player direction
func _iniciar_lanzamiento():
	if recibiendo_daño:
		return
	if not lanzando and jugador_detectado:
		lanzando = true
		anim.play("throwing")
		await anim.animation_finished
		anim.play("idle")
		var bomba = bomba_scene.instantiate()
		get_tree().current_scene.add_child(bomba)
		if jugador.global_position.x > global_position.x:
			bomba.global_position = global_position + Vector2(15, -15)
			bomba.apply_impulse(Vector2(150, -170))
		else:
			bomba.global_position = global_position + Vector2(-15, -5)
			bomba.apply_impulse(Vector2(-170, -150))

		lanzando = false
		timer.start(1.0)