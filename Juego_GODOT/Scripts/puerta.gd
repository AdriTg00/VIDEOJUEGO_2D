## puerta.gd — Door open/close animation controller

extends AnimatedSprite2D

## Lifecycle
func _ready():
	play("open")
	await animation_finished
	await get_tree().create_timer(1.5).timeout
	play("close")
