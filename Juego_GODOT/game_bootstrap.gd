extends Node

func _ready():
	var nivel := 1

	if LaunchToken.load_partida and not LaunchToken.load_partida.is_empty():
		nivel = LaunchToken.load_partida.get("nivel", 1)
		print("BOOTSTRAP | Cargando nivel:", nivel)
	else:
		print("BOOTSTRAP | Nueva partida")

	match nivel:
		1:
			get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")
		2:
			get_tree().change_scene_to_file("res://Escenas/segundo_nivel.tscn")
		3:
			get_tree().change_scene_to_file("res://Escenas/tercer_nivel.tscn")
		_:
			get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")
