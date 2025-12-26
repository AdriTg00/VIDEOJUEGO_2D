extends Node2D

func _ready():
	$puerta_salida_2.jugador_entro_puerta_2do_nivel.connect(_on_puerta_jugador_entro_2)
	

func _on_puerta_jugador_entro_2():
	
	# Aquí cargamos el segundo nivel
	get_tree().change_scene_to_file("res://Escenas/tercer_nivel.tscn")


	
