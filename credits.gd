extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_HomeBtn_pressed():
	pass # Replace with function body.

func _on_ExitBtn_pressed():
	$ConfirmationDialog.popup()

func _on_ConfirmationDialog_confirmed():
	get_tree().quit()

func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)
