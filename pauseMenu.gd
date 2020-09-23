extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if !visible: return
	if event is InputEventKey and not event.is_pressed():
		var typed_event = event as InputEventKey
		if typed_event.scancode == KEY_ESCAPE:
			visible = false
			get_tree().paused = false
