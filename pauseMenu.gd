extends Control

signal unpause()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		if get_tree().paused:
			unpause()
		else:
			pause()

func _on_ResumeBtn_pressed():
	unpause()

func pause():
	get_tree().paused = true
	visible = true		

func unpause():
	get_tree().paused = false
	visible = false
