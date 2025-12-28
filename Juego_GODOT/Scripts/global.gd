extends Node

# ===============================
# ESTADO GLOBAL DEL JUEGO
# ===============================

var death_count := 0

var tiempo_total_nivel1 := 0.0
var tiempo_total_nivel2 := 0.0
var tiempo_total_nivel3 := 0.0

var nivel := 1

var score_nivel1 := 0
var score_nivel2 := 0
var score_nivel3 := 0


# ===============================
# MÉTODOS DE CÁLCULO
# ===============================

func get_tiempo_total() -> float:
	return tiempo_total_nivel1 + tiempo_total_nivel2 + tiempo_total_nivel3


func get_puntuacion_total() -> int:
	return score_nivel1 + score_nivel2 + score_nivel3


# ===============================
# RESET GLOBAL (CLAVE)
# ===============================

func reset_game():
	print("GLOBAL | Reset completo del juego")

	death_count = 0

	tiempo_total_nivel1 = 0.0
	tiempo_total_nivel2 = 0.0
	tiempo_total_nivel3 = 0.0

	score_nivel1 = 0
	score_nivel2 = 0
	score_nivel3 = 0

	nivel = 1
