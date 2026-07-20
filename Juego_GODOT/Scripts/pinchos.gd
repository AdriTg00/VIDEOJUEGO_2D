## pinchos — Spikes hazard with damage-over-time

extends Area2D

@export var damage_per_second: float = 2.0
@export var interval: float = 0.5

var players_in_area: Array = []


## Lifecycle
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var timer = Timer.new()
	timer.wait_time = interval
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_apply_damage)


func _on_body_entered(body):
	if body.name == "Rey":
		players_in_area.append(body)
		print("Jugador entró a los pinchos")


func _on_body_exited(body):
	if body in players_in_area:
		players_in_area.erase(body)


## Applies damage to all players in the hazard area
func _apply_damage():
	for player in players_in_area:
		if player and player.has_method("take_damage"):
			player.take_damage(damage_per_second)
