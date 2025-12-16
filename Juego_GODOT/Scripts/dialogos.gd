extends Node2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

func reproducir(anim_name: String, duracion: float):
	sprite.visible = true
	sprite.play(anim_name)

	timer.stop()
	timer.wait_time = duracion
	timer.start()

	# Bucle manual hasta que el timer termine
	while timer.time_left > 0:
		await sprite.animation_finished
		sprite.play(anim_name) 

	sprite.visible = false
