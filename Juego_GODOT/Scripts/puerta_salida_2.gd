extends Node2D

@onready var anim = $StaticBody2D/AnimatedSprite2D

signal jugador_entro_puerta_2do_nivel

func _on_Area2D_body_entered(body):
	if body.name == "Rey":
		print('Jugador entro a la puerta')  # cambia si tu jugador se llama distinto
		entrar_nivel(body)

func entrar_nivel(jugador):
	anim.play("open")
		# Bloqueamos al jugador completamente
	jugador.bloqueado = true
	jugador.velocity = Vector2.ZERO
	jugador.set_process_input(false)
	await anim.animation_finished

	


	var animacion_jugador = jugador.get_node("AnimatedSprite2D") 
	animacion_jugador.play("door_in")
	await animacion_jugador.animation_finished

	emit_signal("jugador_entro_puerta_2do_nivel")
