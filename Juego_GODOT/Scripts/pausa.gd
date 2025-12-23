extends CanvasLayer

@onready var color_rect := $ColorRect
@onready var vbox := $VBoxContainer
@onready var btn_reanudar := $VBoxContainer/reanudar
@onready var btn_salir := $VBoxContainer/salir
@onready var btn_guardar := $VBoxContainer/guardar

var http: HTTPRequest
var player: Node2D


func _ready():
	# ⚠️ Aseguramos que el juego ARRANCA sin pausa
	get_tree().paused = false

	color_rect.visible = false
	vbox.visible = false

	btn_reanudar.pressed.connect(_on_reanudar_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)
	btn_guardar.pressed.connect(_on_guardar_pressed)

	http = HTTPRequest.new()
	http.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(http)
	http.request_completed.connect(_on_request_completed)

	call_deferred("_buscar_player")


func _buscar_player():
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("PAUSA: No se encontró el player (grupo 'player')")


func _unhandled_input(event):
	if event.is_action_pressed("pausa"):
		_toggle_pause()


func _toggle_pause():
	var paused := not get_tree().paused
	get_tree().paused = paused
	color_rect.visible = paused
	vbox.visible = paused

	if paused:
		btn_reanudar.grab_focus()


func _on_guardar_pressed():
	print("DEBUG | launched_by_launcher =", LaunchToken.launched_by_launcher)
	print("DEBUG | user =", LaunchToken.user_name)

	if player == null:
		push_error("No se puede guardar: player no existe")
		return

	if LaunchToken.launched_by_launcher:
		guardar_remoto()
	else:
		guardar_local()


func guardar_remoto():
	print("→ GUARDADO REMOTO")

	var url := "https://flask-server-9ymz.onrender.com/partidas/guardar"

	var data := {
		"jugador_id": LaunchToken.user_name,
		"nivel": Global.nivel,
		"tiempo": Global.get_tiempo_total(),
		"puntuacion": Global.get_puntuacion_total(),
		"muertes_nivel": Global.death_count,
		"pos_x": player.global_position.x,
		"pos_y": player.global_position.y,
		"tipo": "guardado"
	}

	var err := http.request(
		url,
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		JSON.stringify(data)
	)

	if err != OK:
		push_error("Error enviando guardado remoto")
	else:
		print("Guardado remoto enviado")


func guardar_local():
	print("→ GUARDADO LOCAL")

	var data := {
		"jugador_id": LaunchToken.user_name,
		"nivel": Global.nivel,
		"tiempo": Global.get_tiempo_total(),
		"puntuacion": Global.get_puntuacion_total(),
		"muertes_nivel": Global.death_count,
		"tipo": "local"
	}

	var file := FileAccess.open("user://partida_local.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	print("Partida guardada LOCALMENTE")


func _on_request_completed(result, response_code, headers, body):
	print("Respuesta servidor:", response_code, body.get_string_from_utf8())


func _on_reanudar_pressed():
	get_tree().paused = false
	color_rect.visible = false
	vbox.visible = false


func _on_salir_pressed():
	get_tree().quit()
