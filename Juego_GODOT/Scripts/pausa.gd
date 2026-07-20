## pausa — Pause menu with resume, save, load, and quit

extends CanvasLayer

@onready var color_rect := $ColorRect
@onready var vbox := $VBoxContainer
@onready var resume_btn := $VBoxContainer/reanudar
@onready var quit_btn := $VBoxContainer/salir
@onready var save_btn := $VBoxContainer/guardar

var http: HTTPRequest
var player: Node2D

var _load_btn: Button


## Lifecycle
func _ready():
	get_tree().paused = false
	color_rect.visible = false
	vbox.visible = false

	resume_btn.pressed.connect(_on_resume_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	save_btn.pressed.connect(_on_save_pressed)

	_load_btn = Button.new()
	_load_btn.text = "Cargar"
	_load_btn.pressed.connect(_on_load_pressed)
	vbox.add_child(_load_btn)
	vbox.move_child(_load_btn, vbox.get_child_count() - 2)

	http = HTTPRequest.new()
	http.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(http)
	http.request_completed.connect(_on_request_completed)

	call_deferred("_find_player")


func _find_player():
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("PAUSA: No se encontró el player (grupo 'player')")


func _unhandled_input(event):
	if event.is_action_pressed("pausa"):
		_toggle_pause()


## Toggle pause state
func _toggle_pause():
	var paused := not get_tree().paused
	get_tree().paused = paused
	color_rect.visible = paused
	vbox.visible = paused
	if paused:
		resume_btn.grab_focus()


func _on_save_pressed():
	if player == null:
		push_error("No se puede guardar: player no existe")
		return
	if LaunchToken.launched_by_launcher:
		_save_remote()
	else:
		save_local()


## Save game to remote server
func _save_remote():
	var url := "https://flask-server-9ymz.onrender.com/partidas/guardar"
	var data := _build_save_data("guardado")
	var err := http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(data))
	if err != OK:
		push_error("Error enviando guardado remoto")


## Save game to local disk
func save_local():
	var data := _build_save_data("local")
	var file := FileAccess.open("user://partida_local.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("Partida guardada LOCALMENTE")


func _build_save_data(save_type: String) -> Dictionary:
	return {
		"player_id": LaunchToken.user_name,
		"nivel": Global.nivel,
		"tiempo": Global.get_total_time(),
		"puntuacion": Global.get_total_score(),
		"muertes_nivel": Global.death_count,
		"pos_x": player.global_position.x if player else 0,
		"pos_y": player.global_position.y if player else 0,
		"tipo": save_type
	}


func _on_load_pressed():
	var data := _load_local_save()
	if data.is_empty():
		push_error("No hay partida guardada localmente")
		return

	get_tree().paused = false
	hide()
	GameManager.apply_save_data(data)

	var nivel := Global.nivel
	var path := "res://Escenas/primer_nivel.tscn"
	match nivel:
		2: path = "res://Escenas/segundo_nivel.tscn"
		3: path = "res://Escenas/tercer_nivel.tscn"

	get_tree().change_scene_to_file(path)


## Load save file from disk
func _load_local_save() -> Dictionary:
	if not FileAccess.file_exists("user://partida_local.json"):
		return {}

	var file := FileAccess.open("user://partida_local.json", FileAccess.READ)
	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()
	return json.data if typeof(json.data) == TYPE_DICTIONARY else {}


## Load save file from disk (static version)
static func load_local_save_static() -> Dictionary:
	if not FileAccess.file_exists("user://partida_local.json"):
		return {}
	var file := FileAccess.open("user://partida_local.json", FileAccess.READ)
	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()
	return json.data if typeof(json.data) == TYPE_DICTIONARY else {}


func _on_request_completed(result, response_code, headers, body):
	print("Respuesta servidor:", response_code, body.get_string_from_utf8())


func _on_resume_pressed():
	get_tree().paused = false
	color_rect.visible = false
	vbox.visible = false


func _on_quit_pressed():
	get_tree().quit()
