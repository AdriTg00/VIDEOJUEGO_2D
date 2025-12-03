extends Node2D

func _ready():
	$puerta_salida.jugador_entro_puerta.connect(_on_puerta_jugador_entro)

func _on_puerta_jugador_entro():
	# Aquí cargamos el segundo nivel
	get_tree().change_scene_to_file("res://Escenas/segundo_nivel.tscn")
