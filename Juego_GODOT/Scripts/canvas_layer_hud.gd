extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var timer_label = $timerLabel
@onready var level_section = $level_section
@onready var death_label = $death

@export var hud_offset := Vector2(-500, -250)
@export var suavizado := true
@export var velocidad_suavizado := 5.0
@export var nivel_actual := 1

var camara_actual: Camera2D = null
var running := false
var _tiempo_key := "tiempo_total_nivel1"
var _score_key := "score_nivel1"

func _ready():
	add_to_group("hud")
	match nivel_actual:
		1:
			_tiempo_key = "tiempo_total_nivel1"
			_score_key = "score_nivel1"
		2:
			_tiempo_key = "tiempo_total_nivel2"
			_score_key = "score_nivel2"
		3:
			_tiempo_key = "tiempo_total_nivel3"
			_score_key = "score_nivel3"

	Global.nivel = nivel_actual
	_start_timer()
	death_label.text = "DEATHS: " + str(Global.death_count)
	level_section.text = "LEVEL " + str(nivel_actual)
	score_label.text = "Score: " + str(Global.get(_score_key))

	for nodo in get_children():
		if nodo is AnimatedSprite2D:
			nodo.play("idle")

	_actualizar_camara()
	get_tree().node_added.connect(_on_node_added)

func _start_timer():
	running = true

func stop_timer():
	running = false

func _update_timer_label():
	var t = Global.get(_tiempo_key)
	var minutes = int(t / 60)
	var seconds = int(t) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func get_elapsed_ms() -> int:
	return int(round(Global.get(_tiempo_key) * 1000.0))

func get_elapsed_text() -> String:
	var t = Global.get(_tiempo_key)
	var minutes = int(t / 60)
	var seconds = int(t) % 60
	return "%02d:%02d" % [minutes, seconds]

func añadir_moneda(amount: int):
	var current = Global.get(_score_key)
	Global.set(_score_key, current + amount)
	score_label.text = "Score: " + str(Global.get(_score_key))

func _process(delta: float):
	if running:
		var current = Global.get(_tiempo_key)
		Global.set(_tiempo_key, current + delta)
		_update_timer_label()

	if not camara_actual:
		_actualizar_camara()
		return

	var destino = camara_actual.get_screen_center_position() + hud_offset
	if suavizado:
		transform.origin = transform.origin.lerp(destino, delta * velocidad_suavizado)
	else:
		transform.origin = destino

func actualizar_vida(nueva_vida: int):
	var corazones := []
	for nodo in get_children():
		if nodo is AnimatedSprite2D:
			corazones.append(nodo)

	var vida_actual := corazones.size()

	if nueva_vida < vida_actual:
		for i in range(vida_actual - 1, nueva_vida - 1, -1):
			if i >= 0 and i < corazones.size():
				await _romper_corazon(corazones[i])

func actualizar_muertes():
	Global.death_count += 1
	death_label.text = "DEATHS: " + str(Global.death_count)

func _romper_corazon(corazon: AnimatedSprite2D):
	if not corazon.visible:
		return
	corazon.play("hit")
	await corazon.animation_finished
	corazon.visible = false

func _on_node_added(nodo):
	if nodo is Camera2D and nodo.is_current():
		camara_actual = nodo

func _actualizar_camara():
	var camaras = get_tree().get_nodes_in_group("camaras")
	for c in camaras:
		if c.is_current():
			camara_actual = c
			return

	for nodo in get_tree().root.get_children():
		if nodo is Camera2D and nodo.is_current():
			camara_actual = nodo
			return
