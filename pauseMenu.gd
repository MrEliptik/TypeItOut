extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if !visible: return
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false
		get_tree().paused = false
