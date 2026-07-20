## global — Global game state (times, scores, deaths, level, reset)

extends Node

var player_id: String = ""

var death_count := 0

var tiempo_total_nivel1 := 0.0
var tiempo_total_nivel2 := 0.0
var tiempo_total_nivel3 := 0.0

var nivel := 1

var score_nivel1 := 0
var score_nivel2 := 0
var score_nivel3 := 0


func get_total_time() -> float:
	return tiempo_total_nivel1 + tiempo_total_nivel2 + tiempo_total_nivel3


func get_total_score() -> int:
	return score_nivel1 + score_nivel2 + score_nivel3


## Reset state on death
func reset_game_death():
	print("GLOBAL | Reset completo del juego")

	tiempo_total_nivel1 = 0.0
	tiempo_total_nivel2 = 0.0
	tiempo_total_nivel3 = 0.0

	score_nivel1 = 0
	score_nivel2 = 0
	score_nivel3 = 0

	nivel = 1


## Full game reset
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
