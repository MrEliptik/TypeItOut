extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_PauseMenu_visibility_changed():
	if visible:
		get_tree().paused = true
