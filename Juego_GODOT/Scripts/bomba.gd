## bomba — Timed bomb that explodes and deals damage

extends RigidBody2D

@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var explosion_area = $Area2D
@onready var area_shape = $Area2D/CollisionShape2D


## Lifecycle
func _ready():
	anim.play("idle")
	await get_tree().create_timer(0.5).timeout
	anim.play("bomb_on")
	await get_tree().create_timer(0.5).timeout
	explode()


## Trigger explosion sequence
func explode():
	anim.play("explosion")
	explosion_area.monitoring = true
	area_shape.disabled = false

	await anim.animation_finished

	explosion_area.monitoring = false
	area_shape.disabled = true
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
