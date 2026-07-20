## canvas_layer_dead — Death screen overlay with retry and load options

extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label = $VBoxContainer/Label
@onready var retry_btn = $VBoxContainer/Button

var _load_btn: Button


## Lifecycle
func _ready():
	add_to_group("death_screen")
	self.visible = false
	color_rect.modulate.a = 0.0
	label.modulate.a = 0.0
	retry_btn.modulate.a = 0.0

	retry_btn.pressed.connect(_on_retry_pressed)

	_load_btn = Button.new()
	_load_btn.text = "Cargar partida"
	_load_btn.modulate.a = 0.0
	_load_btn.pressed.connect(_on_load_pressed)
	$VBoxContainer.add_child(_load_btn)


func show_death_screen():
	self.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.7, 1.0)
	tween.tween_property(label, "modulate:a", 1.0, 0.8)
	tween.tween_property(retry_btn, "modulate:a", 1.0, 0.8)
	tween.tween_property(_load_btn, "modulate:a", 1.0, 0.8)


func _on_retry_pressed():
	Global.reset_game_death()
	get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")


func _on_load_pressed():
	var data := _load_local_save()
	if data.is_empty():
		return

	Global.reset_game_death()
	GameManager.apply_save_data(data)

	var nivel := Global.nivel
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
