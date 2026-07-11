## mobile_controls.gd — Mobile touch controls visibility

extends CanvasLayer

## Lifecycle
func _ready():
	if not OS.has_feature("mobile"):
		hide()
	else:
		show()
