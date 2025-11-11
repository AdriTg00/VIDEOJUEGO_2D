extends CharacterBody2D

@export var bomba_scene: PackedScene 
@onready var anim = $AnimatedSprite2D
@onready var timer = $Timer
@onready var detector = $Area2D
@export var gravedad: float = 1200.0
@export var max_caida: float = 1000.0

var jugador_detectado = false
var lanzando = false  
var recibiendo_daño := false
var vida = 5
var muerto := false
var jugador: CharacterBody2D 

func _ready():
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta):
	if recibiendo_daño:
		return
	_aplicar_gravedad(delta)
	move_and_slide()

# --- Detectar jugador ---
func _on_body_entered(body):
	if body.name == "Rey":  
		jugador = body
		jugador_detectado = true
		_iniciar_lanzamiento()  # 

func _on_body_exited(body):
	if body.name == "Rey":
		jugador = null
		jugador_detectado = false
		timer.stop()
		anim.play("idle")

# --- Gravedad ---
func _aplicar_gravedad(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
		velocity.y = min(velocity.y, max_caida)
	else:
		velocity.y = 0

# --- Lógica del temporizador ---
func _on_timer_timeout():
	if jugador_detectado:
		_iniciar_lanzamiento()
		
func recibir_dano(cantidad: int = 1):
	recibiendo_daño = true
	vida -= cantidad
	print("El cerdo recibió daño. Vida restante:", vida)
	
	if vida <= 0:
		_morir()
		return

	# --- Animación y retroceso ---
	anim.play("hit")
	
	var dir_retroceso = sign(global_position.x - jugador.global_position.x)
	velocity.x = dir_retroceso * 50         
	# --- Aplica la física normal una sola vez ---
	move_and_slide()
	velocity.x = 0
	await anim.animation_finished
	recibiendo_daño = false
	
func _morir():
	muerto = true
	var hud = get_tree().root.get_node("Juego/CanvasLayer")
	hud.añadir_moneda(3)
	print("El cerdo ha muerto")
	# Detiene cualquier movimiento o ataque
	velocity = Vector2.ZERO
	# Desactiva las colisiones (para no seguir detectando al jugador)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	# Reproduce la animación de muerte
	anim.play("dead")
	# Espera a que termine la animación antes de eliminar el nodo
	await anim.animation_finished
	# Elimina el cerdo de la escena
	queue_free()

# --- Secuencia de lanzamiento ---
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
		bomba.global_position = global_position + Vector2(-15, -5)
		bomba.apply_impulse(Vector2(-170, -150))
		

		lanzando = false
		timer.start(1.0)  
