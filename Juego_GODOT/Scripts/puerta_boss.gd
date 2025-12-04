extends Node2D

@export var distancia_bajada := 70.0    # ajusta el valor según tu puerta
@export var tiempo_bajada := 1.5


func bajar():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", position.y + distancia_bajada, tiempo_bajada)
	
