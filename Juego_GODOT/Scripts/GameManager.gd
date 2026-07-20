## GameManager — Save/load orchestration and end-game stats submission

extends Node

var save_data := {}
var finished := false
var load_applied := false
var save_loaded := false


## Apply saved data to global state
func apply_save_data(data: Dictionary):
	save_data = data
	load_applied = false
	finished = false

	Global.nivel = int(data.get("nivel", 1))
	Global.death_count = int(data.get("muertes_nivel", 0))

	Global.tiempo_total_nivel1 = float(data.get("tiempo", 0))
	Global.tiempo_total_nivel2 = 0
	Global.tiempo_total_nivel3 = 0

	Global.score_nivel1 = int(data.get("puntuacion", 0))
	Global.score_nivel2 = 0
	Global.score_nivel3 = 0


## Submit final stats to server
func end_game():
	print("DEBUG | end_game() llamado")

	if finished:
		return
	finished = true

	if Global.player_id == "":
		push_error("FIN DE JUEGO | player_id vacío, abortando envío")
		return

	var stats = {
		"jugador_id": Global.player_id,
		"tiempo_total": Global.get_total_time(),
		"puntuacion_total": Global.get_total_score(),
		"niveles_superados": Global.nivel
	}

	print("FIN DE JUEGO | Enviando estadisticas:", stats)
	_send_player_stats(stats)


## Send stats via HTTP
func _send_player_stats(data: Dictionary):
	print("HTTP | Preparando envío de estadísticas")

	var http := HTTPRequest.new()
	http.name = "HTTPRequest_Estadisticas"
	get_tree().root.add_child(http)

	http.request_completed.connect(_on_stats_sent)

	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)

	var err = http.request(
		"https://flask-server-9ymz.onrender.com/jugadores/estadisticas",
		headers,
		HTTPClient.METHOD_POST,
		body
	)

	if err != OK:
		push_error("HTTP | Error al lanzar request: %s" % err)


func _on_stats_sent(result, response_code, headers, body):
	var text = body.get_string_from_utf8()
	print("API RESPUESTA | código:", response_code)
	print("API RESPUESTA | body:", text)

	var http = get_node_or_null("/root/HTTPRequest_Estadisticas")
	if http:
		http.queue_free()

	if response_code != 200:
		push_error("Error actualizando estadísticas del jugador")
