extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label = $VBoxContainer/Label
@onready var boton_retry = $VBoxContainer/Button
@onready var label_stats = $VBoxContainer/stats

func _ready():
	# Inicialmente invisible
	self.visible = false
	color_rect.modulate.a = 0.0
	label.modulate.a = 0.0
	boton_retry.modulate.a = 0.0
	
	boton_retry.pressed.connect(_on_retry_pressed)

func mostrar_pantalla_ganador():
	self.visible = true
	var tween = get_tree().create_tween()
	_actualizar_estadisticas()
	tween.tween_property(color_rect, "modulate:a", 0.7, 1.0)
	tween.tween_property(label, "modulate:a", 1.0, 0.8)
	tween.tween_property(boton_retry, "modulate:a", 1.0, 0.8)
func _actualizar_estadisticas():
	label_stats.text = """
			TIEMPO TOTAL: %.2f s
			PUNTUACIÓN TOTAL: %d
			MUERTES: %d

			Nivel 1 -> Tiempo: %.2f | Score: %d
			Nivel 2 -> Tiempo: %.2f | Score: %d
			Nivel 3 -> Tiempo: %.2f | Score: %d
			""" % [
			Global.get_tiempo_total(),
			Global.get_puntuacion_total(),
			Global.death_count,
			Global.tiempo_total_nivel1, Global.score_nivel1,
			Global.tiempo_total_nivel2, Global.score_nivel2,
			Global.tiempo_total_nivel3, Global.score_nivel3
			]

func _on_retry_pressed():
	Global.reset_game()
	get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")
