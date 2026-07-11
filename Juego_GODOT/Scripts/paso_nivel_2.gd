## paso_nivel_2.gd — Level 2 transition handler

extends Node2D

## Lifecycle
func _ready():
	$puerta_salida.jugador_entro_puerta.connect(_on_puerta_jugador_entro)

func _on_puerta_jugador_entro():
	get_tree().change_scene_to_file("res://Escenas/segundo_nivel.tscn")
