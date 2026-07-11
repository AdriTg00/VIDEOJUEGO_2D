## game_bootstrap — Boot sequence: load save, determine level, navigate
extends Node

## Lifecycle
func _ready():
	print("BOOTSTRAP | Ready")

	while not LaunchToken.listo:
		await get_tree().process_frame

	print("BOOTSTRAP | LaunchToken listo")
	print("BOOTSTRAP | load_partida:", LaunchToken.load_partida)

	if not LaunchToken.load_partida.is_empty():
		print("BOOTSTRAP | Aplicando partida desde launcher")
		GameManager.aplicar_partida(LaunchToken.load_partida)
	else:
		var local_save := _cargar_local_save()
		if not local_save.is_empty():
			print("BOOTSTRAP | Aplicando partida desde guardado local")
			GameManager.aplicar_partida(local_save)
		else:
			print("BOOTSTRAP | Nueva partida")

	var nivel := Global.nivel
	print("BOOTSTRAP | Nivel final:", nivel)

	var path := "res://Escenas/primer_nivel.tscn"
	match nivel:
		2: path = "res://Escenas/segundo_nivel.tscn"
		3: path = "res://Escenas/tercer_nivel.tscn"

	get_tree().change_scene_to_file(path)

## Load save file from disk
func _cargar_local_save() -> Dictionary:
	if not FileAccess.file_exists("user://partida_local.json"):
		return {}
	var file := FileAccess.open("user://partida_local.json", FileAccess.READ)
	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()
	return json.data if typeof(json.data) == TYPE_DICTIONARY else {}
