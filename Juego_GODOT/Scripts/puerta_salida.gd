## exit_door — Exit door with level transition

extends Node2D

@onready var anim = $StaticBody2D/AnimatedSprite2D

signal player_entered_door


func _on_Area2D_body_entered(body):
	if body.name == "Rey":
		print('Jugador entro a la puerta')
		_enter_level(body)


## Handles player entrance animation and emits transition signal
func _enter_level(player):
	anim.play("open")
	player.locked = true
	player.velocity = Vector2.ZERO
	player.set_process_input(false)
	await anim.animation_finished
	var player_anim = player.get_node("AnimatedSprite2D")
	player_anim.play("door_in")
	await player_anim.animation_finished

	emit_signal("player_entered_door")
