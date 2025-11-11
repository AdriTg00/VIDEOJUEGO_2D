extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label = $VBoxContainer/Label
@onready var boton_retry = $VBoxContainer/Button

func _ready():
	# Inicialmente invisible
	self.visible = false
	color_rect.modulate.a = 0.0
	label.modulate.a = 0.0
	boton_retry.modulate.a = 0.0
	
	boton_retry.pressed.connect(_on_retry_pressed)

func mostrar_pantalla_muerte():
	self.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.7, 1.0)
	tween.tween_property(label, "modulate:a", 1.0, 0.8)
	tween.tween_property(boton_retry, "modulate:a", 1.0, 0.8)

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")
