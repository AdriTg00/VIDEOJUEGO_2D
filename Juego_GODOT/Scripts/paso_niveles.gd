extends Node2D

func _ready():
	$puerta_salida.jugador_entro_puerta.connect(_on_puerta_jugador_entro)
	$puerta_salida_2.jugador_entro_puerta_2do_nivel.connect(_on_puerta_jugador_entro_3erNivel())

func _on_puerta_jugador_entro():
	# Aquí cargamos el segundo nivel
	get_tree().change_scene_to_file("res://Escenas/segundo_nivel.tscn")
func _on_puerta_jugador_entro_3erNivel():
	get_tree().change_scene_to_file("res://Escenas/tercer_nivel.tscn")
	
