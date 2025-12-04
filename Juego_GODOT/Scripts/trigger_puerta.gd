extends Area2D
@onready var puerta = get_node("../puerta_boss")
var activado := false

func _on_body_entered(body):
	if activado:
		return
		
	if body.name == "Rey":
		activado = true
		puerta.bajar()
