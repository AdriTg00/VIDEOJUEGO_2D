## moneda — Collectible coin that adds score

extends Area2D

@export var value: int = 1
@onready var anim = $AnimatedSprite2D


## Lifecycle
func _ready():
	anim.play("idle")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.name == "Rey":
		body.add_coin(value)
		queue_free()
