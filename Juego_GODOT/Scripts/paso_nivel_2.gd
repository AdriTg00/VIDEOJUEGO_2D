## level_transition_2 — Level 2 transition handler

extends Node2D


## Lifecycle
func _ready():
	$puerta_salida.player_entered_door.connect(_on_player_entered_door)


func _on_player_entered_door():
	get_tree().change_scene_to_file("res://Escenas/segundo_nivel.tscn")
