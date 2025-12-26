extends Node

var partida := {}

func aplicar_partida(partida_data: Dictionary):
	partida = partida_data

	Global.nivel = int(partida.get("nivel", 1))
	Global.death_count = int(partida.get("muertes_nivel", 0))

	# Tiempo TOTAL (ajústalo luego por nivel)
	Global.tiempo_total_nivel1 = float(partida.get("tiempo", 0))
	Global.tiempo_total_nivel2 = 0
	Global.tiempo_total_nivel3 = 0

	Global.score_nivel1 = int(partida.get("puntuacion", 0))
	Global.score_nivel2 = 0
	Global.score_nivel3 = 0

func fin_de_juego():
	var datos := {
		"jugador_id": LaunchToken.user_name,
		"tiempo_total": Global.get_tiempo_total(),
		"puntuacion_total": Global.get_puntuacion_total(),
		"niveles_superados": 3
	}

	print("FIN DE JUEGO | Enviando estadísticas:", datos)

	_enviar_estadisticas_jugador(datos)

func _enviar_estadisticas_jugador(datos: Dictionary):
	var http := HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(_on_estadisticas_enviadas)

	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(datos)

	http.request(
		"https://flask-server-9ymz.onrender.com/api/jugadores/estadisticas",
		headers,
		HTTPClient.METHOD_POST,
		body
	)
	
func _on_estadisticas_enviadas(result, response_code, headers, body):
	print("API RESPUESTA | código:", response_code)
	print("API RESPUESTA | body:", body.get_string_from_utf8())
