extends Node

# =========================
# ESTADO DE LANZAMIENTO
# =========================
var launched_by_launcher: bool = false
var user_name: String = "LOCAL_DEV"

# =========================
# CARGA DE PARTIDA (opcional)
# =========================
var load_partida_id: String = ""


func _ready():
	leer_launch_token()


func leer_launch_token():
	# Directorio del ejecutable
	var exe_dir := OS.get_executable_path().get_base_dir()
	var root_dir := exe_dir.get_base_dir()
	var token_path := root_dir.path_join("runtime").path_join("launch_token.json")

	# -------------------------
	# MODO LOCAL / NUEVA PARTIDA
	# -------------------------
	if not FileAccess.file_exists(token_path):
		print("DEBUG | Sin launch token → modo local / nueva partida")
		launched_by_launcher = false
		user_name = "LOCAL_DEV"
		load_partida_id = ""
		return

	var file := FileAccess.open(token_path, FileAccess.READ)
	if file == null:
		print("ERROR | No se pudo abrir launch_token.json")
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		print("ERROR | JSON inválido en launch_token.json")
		return

	var data: Dictionary = json.data

	# -------------------------
	# DATOS BÁSICOS
	# -------------------------
	launched_by_launcher = data.get("launched_by", "") == "launcher"
	user_name = data.get("user", "LOCAL_DEV")

	# -------------------------
	# CARGA DE PARTIDA (OPCIONAL)
	# -------------------------
	load_partida_id = data.get("load_partida_id", "")

	if load_partida_id != "":
		print("LaunchToken | Cargar partida:", load_partida_id)
	else:
		print("LaunchToken | Nueva partida")

	print("LaunchToken | Usuario:", user_name)
