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
