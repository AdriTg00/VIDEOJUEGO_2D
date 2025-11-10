extends RigidBody2D

@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready():
	anim.play("idle")
	await get_tree().create_timer(0.5).timeout
	anim.play("bomb_on")
	await get_tree().create_timer(0.5).timeout
	explotar()

func explotar():
	anim.play("explosion")
	await anim.animation_finished
	queue_free()  # elimina la bomba
