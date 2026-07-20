## door_trigger — One-shot door trigger for boss room

extends Area2D
@onready var door = get_node("../puerta_boss")
var triggered := false

func _on_body_entered(body):
	if triggered:
		return
	if body.name == "Rey":
		triggered = true
		door.lower()
