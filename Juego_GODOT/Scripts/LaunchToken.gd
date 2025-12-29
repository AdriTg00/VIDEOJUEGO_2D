extends Node

# ==================================
# ESTADO DEL LANZAMIENTO
# ==================================
var launched_by_launcher: bool = false
var user_name: String = "LOCAL_DEV"
var load_partida: Dictionary = {}
var configuracion: Dictionary = {}

var listo: bool = false


# ==================================
# CICLO DE VIDA
# ==================================
func _ready():
	print("LAUNCHTOKEN | _ready()")
	call_deferred("_leer_launch_token")


# ==================================
# LECTURA DEL TOKEN
# ==================================
func _leer_launch_token():
	print("LAUNCHTOKEN | Leyendo token...")

	var exe_path := OS.get_executable_path()
	print("LAUNCHTOKEN | exe_path =", exe_path)

	if exe_path == "":
		print("LAUNCHTOKEN | exe_path vacío → modo local")
		_modo_local()
		return

	var exe_dir := exe_path.get_base_dir()
	var root_dir := exe_dir.get_base_dir()
	var token_path := root_dir.path_join("runtime").path_join("launch_token.json")

	print("LAUNCHTOKEN | token_path =", token_path)

	if not FileAccess.file_exists(token_path):
		print("LAUNCHTOKEN | no existe token → modo local")
		_modo_local()
		return

	var file := FileAccess.open(token_path, FileAccess.READ)
	if file == null:
		print("LAUNCHTOKEN | no se pudo abrir el token")
		_modo_local()
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK or typeof(json.data) != TYPE_DICTIONARY:
		print("LAUNCHTOKEN | token inválido")
		_modo_local()
		return

	var data: Dictionary = json.data
	print("LAUNCHTOKEN | data raw =", data)

	# ------------------------------
	# Datos básicos
	# ------------------------------
	launched_by_launcher = data.get("launched_by", "") == "launcher"
	user_name = data.get("user", "LOCAL_DEV")
	load_partida = data.get("load_partida", {})
	configuracion = data.get("configuracion", {})

	# ------------------------------
	# Persistimos jugador_id global
	# ------------------------------
	Global.jugador_id = user_name
	print("GLOBAL | jugador_id establecido desde LaunchToken:", Global.jugador_id)

	# ------------------------------
	# Aplicar configuración SI EXISTE
	# ------------------------------
	if configuracion.size() > 0:
		_aplicar_configuracion()
	else:
		print("LAUNCHTOKEN | No hay configuración → usando valores por defecto")

	print("LAUNCHTOKEN | launcher =", launched_by_launcher)
	print("LAUNCHTOKEN | user =", user_name)
	print("LAUNCHTOKEN | load_partida =", load_partida)
	print("LAUNCHTOKEN | configuracion =", configuracion)

	listo = true
	print("LAUNCHTOKEN | listo = true")


# ==================================
# MODO LOCAL (SIN LAUNCHER)
# ==================================
func _modo_local():
	print("LAUNCHTOKEN | _modo_local()")

	launched_by_launcher = false
	user_name = "LOCAL_DEV"
	load_partida = {}
	configuracion = {}

	Global.jugador_id = user_name
	print("GLOBAL | jugador_id establecido en modo local:", Global.jugador_id)

	listo = true


# ==================================
# APLICAR CONFIGURACIÓN
# ==================================
func _aplicar_configuracion():
	print("⚙ Aplicando configuración desde launcher:", configuracion)

	# -------- Volumen música --------
	var vol_music := float(configuracion.get("volumen_musica", 100)) / 100.0
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(vol_music)
	)

	# -------- Volumen SFX --------
	var vol_sfx := float(configuracion.get("volumen_sfx", 100)) / 100.0
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(vol_sfx)
	)

	# -------- Resolución --------
	var res_text: String = str(configuracion.get("resolucion", "640x480"))
	var parts: PackedStringArray = res_text.split("x")

	if parts.size() == 2:
		var size := Vector2i(parts[0].to_int(), parts[1].to_int())
		DisplayServer.window_set_size(size)
		print("CONFIG | Resolución aplicada:", size)

	# -------- Modo pantalla --------
	if configuracion.get("modo_pantalla", "ventana") == "completa":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		print("CONFIG | Modo pantalla: FULLSCREEN")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		print("CONFIG | Modo pantalla: WINDOWED")
