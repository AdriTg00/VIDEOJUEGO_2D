extends Node

func _ready():
	print("BOOTSTRAP | Ready")

	await get_tree().process_frame
	await get_tree().process_frame
	var nivel := 1

	if LaunchToken.load_partida and not LaunchToken.load_partida.is_empty():
		nivel = LaunchToken.load_partida.get("nivel", 1)
		print("BOOTSTRAP | Cargando nivel:", nivel)
	else:
		print("BOOTSTRAP | Nueva partida")
	
	print("BOOTSTRAP | LaunchToken listo:", LaunchToken.listo)
	print("BOOTSTRAP | load_partida:", LaunchToken.load_partida)


	match nivel:
		1:
			print("BOOTSTRAP | Cambiando a nivel:", nivel)

			get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")
		2:
			print("BOOTSTRAP | Cambiando a nivel:", nivel)

			get_tree().change_scene_to_file("res://Escenas/segundo_nivel.tscn")
		3:
			print("BOOTSTRAP | Cambiando a nivel:", nivel)

			get_tree().change_scene_to_file("res://Escenas/tercer_nivel.tscn")
		_:
			print("BOOTSTRAP | Cambiando a nivel:", nivel)

			get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")
