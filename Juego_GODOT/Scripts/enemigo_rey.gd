extends CharacterBody2D

# --- Nodos ---
@onready var anim = $AnimatedSprite2D
@onready var detector_area = $Area2D
@onready var detector_salto = $detector_salto
@onready var gruñido = $"gruñido_cerdo"
@onready var area_ataque = $attackArea
@onready var dialogo = $dialogo



# --- Parámetros exportados ---
@export var margen_colision: float = 20.0
@export var velocidad: float = 30.0
@export var gravedad: float = 1200.0
@export var max_caida: float = 1000.0
@export var rango_persecucion: float = 250.0
@export var tiempo_idle_colision: float = 1.0 

# --- Estados ---
var jugador: CharacterBody2D = null
var muerto := false
var recibiendo_daño := false
var direccion := 1
var en_persecucion := false
var invulnerable := false
var vida = 10
var velocidad_sumar := 0


# --- Constantes ---

const IMPULSO_SALTO = -400.0


func _ready():
	detector_area.body_entered.connect(_on_jugador_entro)
	detector_area.body_exited.connect(_on_jugador_salio)
	area_ataque.body_entered.connect(_on_attack_area_body_entered)
	
	


func _physics_process(delta):
	if muerto:
		return
	_aplicar_gravedad(delta)
	
	if recibiendo_daño:
		move_and_slide()
		return

	if en_persecucion and jugador:
		_perseguir_jugador()

	move_and_slide()


# --- GRAVEDAD ---
func _aplicar_gravedad(delta):
	# Aumenta la velocidad Y sólo si no está en el suelo
	if not is_on_floor():
		velocity.y += gravedad * delta
		velocity.y = min(velocity.y, max_caida)
	else:
		velocity.y = 0


# --- PERSEGUIR AL JUGADOR ---
func _perseguir_jugador():
	var dist = global_position.distance_to(jugador.global_position)
	# Dirección hacia el jugador
	var dir = sign(jugador.global_position.x - global_position.x)
	if dir < 0:
		velocity.x = dir * velocidad - velocidad_sumar
	else:
		velocity.x = dir * velocidad + velocidad_sumar
	anim.flip_h = dir > 0
	anim.play("run")


	# Si ya está tocando al jugador
	


# --- FUNCIÓN NUEVA ---
func _colisiona_con_jugador() -> bool:
	if jugador:
		var dx = abs(global_position.x - jugador.global_position.x)
		var dy = abs(global_position.y - jugador.global_position.y)
		return dx < margen_colision and dy < margen_colision 
	return false



func recibir_dano(cantidad: int = 1):
	velocidad_sumar += 10
	dialogo.reproducir("angry", 2.0)

	if muerto or invulnerable:
		return
	recibiendo_daño = true
	vida -= cantidad
	print("El cerdo recibió daño. Vida restante:", vida)
	if vida <= 0:
		_morir()
		return
	invulnerable = true

	anim.play("hit")

	var dir_retroceso = 0
	if jugador:
		dir_retroceso = sign(global_position.x - jugador.global_position.x)
	else:
		dir_retroceso = -direccion  # retrocede hacia el lado opuesto al que mira

	velocity.x = dir_retroceso * 50
	move_and_slide()
	await anim.animation_finished
	recibiendo_daño = false
	invulnerable = false

	
	

func _morir():
	muerto = true
	en_persecucion = false
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



# --- DETECCIÓN ---
func _on_jugador_entro(cuerpo):
	if cuerpo.name == "Rey":
		gruñido.play()
		jugador = cuerpo
		en_persecucion = true
		print("Jugador detectado:", jugador.name)
	


func _on_jugador_salio(cuerpo):
	if recibiendo_daño:
		return  # Ignora la salida durante el hit
	if cuerpo == jugador:
		jugador = null
		en_persecucion = false
		print("Jugador fuera de rango, vuelve a patrullar")


func _on_attack_area_body_entered(body: Node2D) -> void:
	
	if not body:
			return
	if not body.has_method("recibir_dano"):
			return
	if body and body.is_inside_tree() and body.has_method("recibir_dano"):
		en_persecucion = false
		velocity.x = 0
		anim.play("attack")
		body.recibir_dano(1)
		await anim.animation_finished
		anim.play("idle")
		var tiempo := 1
		await get_tree().create_timer(tiempo).timeout
		en_persecucion = true
	
		
