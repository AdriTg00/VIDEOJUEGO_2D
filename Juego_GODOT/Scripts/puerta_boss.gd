## boss_door — Boss door with drop animation

extends Node2D

@export var drop_distance := 70.0
@export var drop_time := 1.5


## Lowers the door using a tween
func lower():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", position.y + drop_distance, drop_time)
