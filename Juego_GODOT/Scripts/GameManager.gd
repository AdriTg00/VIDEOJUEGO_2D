extends Node

var partida := {}
var fin_ejecutado := false
var carga_aplicada := false
var partida_cargada := false


func aplicar_partida(partida_data: Dictionary):
	partida = partida_data
	carga_aplicada = false

	Global.nivel = int(partida.get("nivel", 1))
	Global.death_count = int(partida.get("muertes_nivel", 0))

	Global.tiempo_total_nivel1 = float(partida.get("tiempo", 0))
	Global.tiempo_total_nivel2 = 0
	Global.tiempo_total_nivel3 = 0

	Global.score_nivel1 = int(partida.get("puntuacion", 0))
	Global.score_nivel2 = 0
	Global.score_nivel3 = 0


func fin_de_juego():
	print("DEBUG | fin_de_juego() llamado")

	if fin_ejecutado:
		return
	fin_ejecutado = true

	# 🔑 VALIDACIÓN CLAVE
	if Global.jugador_id == "":
		push_error("FIN DE JUEGO | jugador_id vacío, abortando envío")
		return

	var datos = {
		"jugador_id": Global.jugador_id,
		"tiempo_total": Global.get_tiempo_total(),
		"puntuacion_total": Global.get_puntuacion_total(),
		"niveles_superados": Global.nivel
	}

	print("FIN DE JUEGO | Enviando estadisticas:", datos)
	_enviar_estadisticas_jugador(datos)


func _enviar_estadisticas_jugador(datos: Dictionary):
	print("HTTP | Preparando envío de estadísticas")

	var http := HTTPRequest.new()
	http.name = "HTTPRequest_Estadisticas"
	get_tree().root.add_child(http) #NO al GameManager

	http.request_completed.connect(_on_estadisticas_enviadas)

	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(datos)

	var err = http.request(
		"https://flask-server-9ymz.onrender.com/jugadores/estadisticas",
		headers,
		HTTPClient.METHOD_POST,
		body
	)

	if err != OK:
		push_error("HTTP | Error al lanzar request: %s" % err)



func _on_estadisticas_enviadas(result, response_code, headers, body):
	var text = body.get_string_from_utf8()
	print("API RESPUESTA | código:", response_code)
	print("API RESPUESTA | body:", text)

	var http = get_node_or_null("/root/HTTPRequest_Estadisticas")
	if http:
		http.queue_free()

	if response_code != 200:
		push_error("Error actualizando estadísticas del jugador")
