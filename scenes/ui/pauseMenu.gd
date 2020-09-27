extends Control

const home_scene = "res://scenes/ui/titlescreen.tscn"

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

func set_words(words):
	for word in words:
		$ScrollContainer/Words.text += str(word["word"]+": "+word["definition"]) + "\n"

func _on_ExitBtn_pressed():
	if !visible: return
	$ConfirmationDialog.popup()

func _on_HomeBtn_pressed():
	get_tree().paused = false
	get_tree().change_scene(home_scene)

func _on_ConfirmationDialog_confirmed():
	get_tree().quit()
