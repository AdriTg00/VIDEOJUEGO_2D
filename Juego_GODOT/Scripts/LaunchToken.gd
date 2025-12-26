extends Node

var launched_by_launcher: bool = false
var user_name: String = "LOCAL_DEV"
var load_partida: Dictionary = {}

var listo: bool = false   

func _ready():
	print("LAUNCHTOKEN | _ready()")
	call_deferred("_leer_launch_token")


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

	launched_by_launcher = data.get("launched_by", "") == "launcher"
	user_name = data.get("user", "LOCAL_DEV")
	load_partida = data.get("load_partida", {})

	print("LAUNCHTOKEN | launcher =", launched_by_launcher)
	print("LAUNCHTOKEN | user =", user_name)
	print("LAUNCHTOKEN | load_partida =", load_partida)

	listo = true
	print("LAUNCHTOKEN | listo = true")


func _modo_local():
	print("LAUNCHTOKEN | _modo_local()")
	launched_by_launcher = false
	user_name = "LOCAL_DEV"
	load_partida = {}
	listo = true
