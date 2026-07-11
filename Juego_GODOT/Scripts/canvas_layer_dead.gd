## canvas_layer_dead — Death screen overlay with retry and load options
extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label = $VBoxContainer/Label
@onready var boton_retry = $VBoxContainer/Button

var _btn_cargar: Button

## Lifecycle
func _ready():
	add_to_group("death_screen")
	self.visible = false
	color_rect.modulate.a = 0.0
	label.modulate.a = 0.0
	boton_retry.modulate.a = 0.0

	boton_retry.pressed.connect(_on_retry_pressed)

	_btn_cargar = Button.new()
	_btn_cargar.text = "Cargar partida"
	_btn_cargar.modulate.a = 0.0
	_btn_cargar.pressed.connect(_on_cargar_pressed)
	$VBoxContainer.add_child(_btn_cargar)

func mostrar_pantalla_muerte():
	self.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.7, 1.0)
	tween.tween_property(label, "modulate:a", 1.0, 0.8)
	tween.tween_property(boton_retry, "modulate:a", 1.0, 0.8)
	tween.tween_property(_btn_cargar, "modulate:a", 1.0, 0.8)

func _on_retry_pressed():
	Global.reset_game_death()
	get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")

func _on_cargar_pressed():
	var data := _cargar_local_save()
	if data.is_empty():
		return

	Global.reset_game_death()
	GameManager.aplicar_partida(data)

	var nivel := Global.nivel
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
