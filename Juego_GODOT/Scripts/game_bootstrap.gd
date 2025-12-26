extends Node

func _ready():
	print("BOOTSTRAP | Ready")

	#  Esperar a que LaunchToken termine
	while not LaunchToken.listo:
		await get_tree().process_frame

	print("BOOTSTRAP | LaunchToken listo")
	print("BOOTSTRAP | load_partida:", LaunchToken.load_partida)

	# Aplicar partida (si existe)
	if not LaunchToken.load_partida.is_empty():
		print("BOOTSTRAP | Aplicando partida")
		GameManager.aplicar_partida(LaunchToken.load_partida)
	else:
		print("BOOTSTRAP | Nueva partida")

	# Decidir nivel UNA SOLA VEZ
	var nivel := Global.nivel
	print("BOOTSTRAP | Nivel final:", nivel)

	# 4️⃣ Cambiar de escena
	match nivel:
		1:
			get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")
		2:
			get_tree().change_scene_to_file("res://Escenas/segundo_nivel.tscn")
		3:
			get_tree().change_scene_to_file("res://Escenas/tercer_nivel.tscn")
		_:
			get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")
