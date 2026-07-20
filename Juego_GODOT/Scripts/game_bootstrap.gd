## game_bootstrap — Boot sequence: load save, determine level, navigate

extends Node


## Lifecycle
func _ready():
	print("BOOTSTRAP | Ready")

	while not LaunchToken.ready_flag:
		await get_tree().process_frame

	print("BOOTSTRAP | LaunchToken ready")
	print("BOOTSTRAP | load_data:", LaunchToken.load_data)

	if not LaunchToken.load_data.is_empty():
		print("BOOTSTRAP | Aplicando partida desde launcher")
		GameManager.apply_save_data(LaunchToken.load_data)
	else:
		var local_save := _load_local_save()
		if not local_save.is_empty():
			print("BOOTSTRAP | Aplicando partida desde guardado local")
			GameManager.apply_save_data(local_save)
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
func _load_local_save() -> Dictionary:
	if not FileAccess.file_exists("user://partida_local.json"):
		return {}
	var file := FileAccess.open("user://partida_local.json", FileAccess.READ)
	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()
	return json.data if typeof(json.data) == TYPE_DICTIONARY else {}
