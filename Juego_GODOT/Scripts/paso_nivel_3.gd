## level_transition_3 — Level 3 transition handler

extends Node2D


## Lifecycle
func _ready():
	$puerta_salida_2.player_entered_door_level2.connect(_on_player_entered_door_2)


func _on_player_entered_door_2():
	get_tree().change_scene_to_file("res://Escenas/tercer_nivel.tscn")
