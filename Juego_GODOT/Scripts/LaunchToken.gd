extends Node

var launch_data := {}
var launched_by_launcher := false
var user_name: String


func _ready():
	leer_launch_token()


func leer_launch_token():
	var base_dir := OS.get_executable_path().get_base_dir()
	var token_path := base_dir.path_join("runtime").path_join("launch_token.json")

	if not FileAccess.file_exists(token_path):
		print("No se encontró launch_token.json (ejecución directa)")
		return

	var file := FileAccess.open(token_path, FileAccess.READ)
	if file == null:
		print("No se pudo abrir launch_token.json")
		return

	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err := json.parse(content)

	if err != OK:
		print("Error parseando JSON:", json.get_error_message())
		return

	launch_data = json.data
	launched_by_launcher = launch_data.get("launched_by") == "launcher"
	user_name = launch_data.get("user")

	print("Juego lanzado por launcher:", launched_by_launcher)
	print("Usuario:", user_name)
