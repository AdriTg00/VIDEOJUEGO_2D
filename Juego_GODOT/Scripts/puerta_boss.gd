## puerta_boss.gd — Boss door with drop animation

extends Node2D

@export var distancia_bajada := 70.0
@export var tiempo_bajada := 1.5

## Lowers the door using a tween
func bajar():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", position.y + distancia_bajada, tiempo_bajada)
