## canvas_layer_hud — HUD overlay with score, timer, death counter, and camera-follow

extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var timer_label = $timerLabel
@onready var level_section = $level_section
@onready var death_label = $death

@export var hud_offset := Vector2(-500, -250)
@export var smooth := true
@export var smooth_speed := 5.0
@export var current_level := 1

var current_camera: Camera2D = null
var running := false
var _time_key := "tiempo_total_nivel1"
var _score_key := "score_nivel1"


## Lifecycle
func _ready():
	add_to_group("hud")
	match current_level:
		1:
			_time_key = "tiempo_total_nivel1"
			_score_key = "score_nivel1"
		2:
			_time_key = "tiempo_total_nivel2"
			_score_key = "score_nivel2"
		3:
			_time_key = "tiempo_total_nivel3"
			_score_key = "score_nivel3"

	Global.nivel = current_level
	_start_timer()
	death_label.text = "DEATHS: " + str(Global.death_count)
	level_section.text = "LEVEL " + str(current_level)
	score_label.text = "Score: " + str(Global.get(_score_key))

	for node in get_children():
		if node is AnimatedSprite2D:
			node.play("idle")

	_update_camera()
	get_tree().node_added.connect(_on_node_added)


func _start_timer():
	running = true


func stop_timer():
	running = false


func _update_timer_label():
	var t = Global.get(_time_key)
	var minutes = int(t / 60)
	var seconds = int(t) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func get_elapsed_ms() -> int:
	return int(round(Global.get(_time_key) * 1000.0))


func get_elapsed_text() -> String:
	var t = Global.get(_time_key)
	var minutes = int(t / 60)
	var seconds = int(t) % 60
	return "%02d:%02d" % [minutes, seconds]


func add_coin(amount: int):
	var current = Global.get(_score_key)
	Global.set(_score_key, current + amount)
	score_label.text = "Score: " + str(Global.get(_score_key))


## Physics
func _process(delta: float):
	if running:
		var current = Global.get(_time_key)
		Global.set(_time_key, current + delta)
		_update_timer_label()

	if not current_camera:
		_update_camera()
		return

	var target = current_camera.get_screen_center_position() + hud_offset
	if smooth:
		transform.origin = transform.origin.lerp(target, delta * smooth_speed)
	else:
		transform.origin = target


## Health — animate and remove hearts
func update_health(new_hp: int):
	var hearts := []
	for node in get_children():
		if node is AnimatedSprite2D:
			hearts.append(node)

	var current_hp := hearts.size()

	if new_hp < current_hp:
		var lose = current_hp - new_hp
		for i in range(lose):
			await _break_heart(hearts[i])


func update_deaths():
	Global.death_count += 1
	death_label.text = "DEATHS: " + str(Global.death_count)


func _break_heart(heart: AnimatedSprite2D):
	if not heart.visible:
		return
	heart.play("hit")
	await heart.animation_finished
	heart.visible = false


func _on_node_added(node):
	if node is Camera2D and node.is_current():
		current_camera = node


func _update_camera():
	var cameras = get_tree().get_nodes_in_group("camaras")
	for c in cameras:
		if c.is_current():
			current_camera = c
			return

	for node in get_tree().root.get_children():
		if node is Camera2D and node.is_current():
			current_camera = node
			return
