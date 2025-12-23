extends CanvasLayer

@onready var color_rect := $ColorRect
@onready var vbox := $VBoxContainer
@onready var btn_reanudar := $VBoxContainer/reanudar
@onready var btn_salir := $VBoxContainer/salir
@onready var btn_guardar := $VBoxContainer/guardar

var http: HTTPRequest


func _ready():
	color_rect.visible = false
	vbox.visible = false

	btn_reanudar.pressed.connect(_on_reanudar_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)
	btn_guardar.pressed.connect(_on_guardar_pressed)

	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)


func _unhandled_input(event):
	if event.is_action_pressed("pausa"):
		_toggle_pause()


func _toggle_pause():
	var is_paused := not get_tree().paused
	get_tree().paused = is_paused
	color_rect.visible = is_paused
	vbox.visible = is_paused

	if is_paused:
		btn_reanudar.grab_focus()


func _on_guardar_pressed():
	var url := "https://flask-server-9ymz.onrender.com/partidas/guardar"

	var data := {
		"jugador_id": LaunchToken.user_name,
		"nivel": Global.nivel,
		"tiempo": Global.get_tiempo_total(),
		"puntuacion": Global.get_puntuacion_total(),
		"muertes_nivel": Global.death_count,
		"tipo": "guardado"
	}

	var json_data := JSON.stringify(data)
	var headers := ["Content-Type: application/json"]

	var err := http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_data
	)

	if err != OK:
		print("Error enviando guardado:", err)
	else:
		print("Guardado enviado al servidor")


func _on_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	print("📥 Respuesta servidor:", response_code, response)

	if response_code == 200:
		print("Partida guardada correctamente")
	else:
		print("Error al guardar partida")


func _on_reanudar_pressed():
	get_tree().paused = false
	color_rect.visible = false
	vbox.visible = false


func _on_salir_pressed():
	get_tree().quit()
