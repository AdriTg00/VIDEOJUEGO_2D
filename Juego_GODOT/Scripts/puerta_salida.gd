## puerta_salida.gd — Exit door with level transition

extends Node2D

@onready var anim = $StaticBody2D/AnimatedSprite2D

signal jugador_entro_puerta

func _on_Area2D_body_entered(body):
	if body.name == "Rey":
		print('Jugador entro a la puerta')
		entrar_nivel(body)

## Handles player entrance animation and emits transition signal
func entrar_nivel(jugador):
	anim.play("open")
	jugador.bloqueado = true
	jugador.velocity = Vector2.ZERO
	jugador.set_process_input(false)
	await anim.animation_finished
	var animacion_jugador = jugador.get_node("AnimatedSprite2D")
	animacion_jugador.play("door_in")
	await animacion_jugador.animation_finished

	emit_signal("jugador_entro_puerta")
