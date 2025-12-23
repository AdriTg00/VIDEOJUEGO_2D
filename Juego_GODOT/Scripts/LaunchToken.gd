extends Node

var launched_by_launcher := false
var user_name: String = "LOCAL_DEV"

func _ready():
	leer_launch_token()

func leer_launch_token():
	var exe_dir := OS.get_executable_path().get_base_dir()
	var root_dir := exe_dir.get_base_dir()
	var token_path := root_dir.path_join("runtime").path_join("launch_token.json")

	if not FileAccess.file_exists(token_path):
		print("No hay launch token → modo local")
		launched_by_launcher = false
		user_name = "LOCAL_DEV"
		return

	var file := FileAccess.open(token_path, FileAccess.READ)
	if file == null:
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return

	var data = json.data
	launched_by_launcher = data.get("launched_by") == "launcher"
	user_name = data.get("user", "LOCAL_DEV")

	print("Launch token detectado | Usuario:", user_name)
