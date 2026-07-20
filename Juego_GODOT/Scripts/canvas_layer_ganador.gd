## canvas_layer_ganador — Win screen overlay with stats display

extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label = $VBoxContainer/Label
@onready var retry_btn = $VBoxContainer/Button
@onready var label_stats = $VBoxContainer/stats


## Lifecycle
func _ready():
	add_to_group("win_screen")
	self.visible = false
	color_rect.modulate.a = 0.0
	label.modulate.a = 0.0
	retry_btn.modulate.a = 0.0

	retry_btn.pressed.connect(_on_retry_pressed)


func show_win_screen():
	self.visible = true
	_update_stats()
	label_stats.modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.7, 1.0)
	tween.tween_property(label, "modulate:a", 1.0, 0.8)
	tween.tween_property(retry_btn, "modulate:a", 1.0, 0.8)
	tween.tween_property(label_stats, "modulate:a", 1.0, 1.2)


func _update_stats():
	label_stats.text = """
			TIEMPO TOTAL: %.2f s
			PUNTUACIÓN TOTAL: %d
			MUERTES: %d

			Nivel 1 -> Tiempo: %.2f | Score: %d
			Nivel 2 -> Tiempo: %.2f | Score: %d
			Nivel 3 -> Tiempo: %.2f | Score: %d
			""" % [
			Global.get_total_time(),
			Global.get_total_score(),
			Global.death_count,
			Global.tiempo_total_nivel1, Global.score_nivel1,
			Global.tiempo_total_nivel2, Global.score_nivel2,
			Global.tiempo_total_nivel3, Global.score_nivel3
			]


func _on_retry_pressed():
	Global.reset_game()
	get_tree().change_scene_to_file("res://Escenas/primer_nivel.tscn")
