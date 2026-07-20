## dialog — Animated dialog display with auto-hide

extends Node2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer


## Play animation for given duration
func play(anim_name: String, duration: float):
	sprite.visible = true
	sprite.play(anim_name)

	timer.stop()
	timer.wait_time = duration
	timer.start()

	while timer.time_left > 0:
		await sprite.animation_finished
		sprite.play(anim_name)

	sprite.visible = false
