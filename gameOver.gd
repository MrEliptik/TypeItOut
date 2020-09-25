extends Control

const home_scene = "res://scenes/ui/titlescreen.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_RetryBtn_pressed():
	if !visible: return
	Engine.time_scale = 1.0
	Inventory.clear_inventory()
	get_tree().reload_current_scene()
	visible = false

func _on_HomeBtn_pressed():
	Engine.time_scale = 1.0
	get_tree().change_scene(home_scene)

func _on_ExitBtn_pressed():
	if !visible: return
	$ConfirmationDialog.popup()

func _on_ConfirmationDialog_confirmed():
	get_tree().quit()
