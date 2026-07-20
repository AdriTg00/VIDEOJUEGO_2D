## LaunchToken — Launch token reader and configuration applier

extends Node

var launched_by_launcher: bool = false
var user_name: String = "LOCAL_DEV"
var load_data: Dictionary = {}
var config: Dictionary = {}

var ready_flag: bool = false


## Lifecycle
func _ready():
	print("LAUNCHTOKEN | _ready()")
	call_deferred("_read_launch_token")


## Reads and parses the launch token file from the launcher
func _read_launch_token():
	print("LAUNCHTOKEN | Leyendo token...")

	var exe_path := OS.get_executable_path()
	print("LAUNCHTOKEN | exe_path =", exe_path)

	if exe_path == "":
		print("LAUNCHTOKEN | exe_path vacío → modo local")
		_local_mode()
		return

	var exe_dir := exe_path.get_base_dir()
	var root_dir := exe_dir.get_base_dir()
	var token_path := root_dir.path_join("runtime").path_join("launch_token.json")

	print("LAUNCHTOKEN | token_path =", token_path)

	if not FileAccess.file_exists(token_path):
		print("LAUNCHTOKEN | no existe token → modo local")
		_local_mode()
		return

	var file := FileAccess.open(token_path, FileAccess.READ)
	if file == null:
		print("LAUNCHTOKEN | no se pudo abrir el token")
		_local_mode()
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK or typeof(json.data) != TYPE_DICTIONARY:
		print("LAUNCHTOKEN | token inválido")
		_local_mode()
		return

	var data: Dictionary = json.data
	print("LAUNCHTOKEN | data raw =", data)

	launched_by_launcher = data.get("launched_by", "") == "launcher"
	user_name = data.get("user", "LOCAL_DEV")
	load_data = data.get("load_partida", {})
	config = data.get("configuracion", {})

	Global.player_id = user_name
	print("GLOBAL | player_id establecido desde LaunchToken:", Global.player_id)

	if config.size() > 0:
		_apply_config()
	else:
		print("LAUNCHTOKEN | No hay configuración → usando valores por defecto")

	print("LAUNCHTOKEN | launcher =", launched_by_launcher)
	print("LAUNCHTOKEN | user =", user_name)
	print("LAUNCHTOKEN | load_data =", load_data)
	print("LAUNCHTOKEN | config =", config)

	ready_flag = true
	print("LAUNCHTOKEN | ready_flag = true")


## Sets local defaults when no launcher token is present
func _local_mode():
	print("LAUNCHTOKEN | _local_mode()")

	launched_by_launcher = false
	user_name = "LOCAL_DEV"
	load_data = {}
	config = {}

	Global.player_id = user_name
	print("GLOBAL | player_id establecido en modo local:", Global.player_id)

	ready_flag = true


## Applies volume, resolution, and display settings from config
func _apply_config():
	print("⚙ Aplicando configuración desde launcher:", config)

	var vol_music := float(config.get("volumen_musica", 100)) / 100.0
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(vol_music)
	)

	var vol_sfx := float(config.get("volumen_sfx", 100)) / 100.0
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(vol_sfx)
	)

	var res_text: String = str(config.get("resolucion", "640x480"))
	var parts: PackedStringArray = res_text.split("x")

	if parts.size() == 2:
		var size := Vector2i(parts[0].to_int(), parts[1].to_int())

		if config.get("modo_pantalla", "ventana") != "completa":
			call_deferred("_apply_resolution", size)
		else:
			print("CONFIG | Fullscreen activo → resolución ignorada")

	if config.get("modo_pantalla", "ventana") == "completa":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		print("CONFIG | Modo pantalla: FULLSCREEN")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		print("CONFIG | Modo pantalla: WINDOWED")


## Applies window resolution after a deferred frame
func _apply_resolution(size: Vector2i):
	await get_tree().process_frame
	DisplayServer.window_set_size(size)
	print("CONFIG | Resolución aplicada (deferred):", size)
