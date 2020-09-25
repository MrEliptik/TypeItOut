extends Control

const game_scene = "res://game.tscn"
#const settings_scene = preload("res://scenes/ui/settings.tscn")
const credits_scene = preload("res://scenes/ui/credits.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_PlayBtn_pressed():
	get_tree().change_scene(game_scene)

func _on_SettingsBtn_pressed():
	pass # Replace with function body.
	#add_child(settings_scene.instance)

func _on_CreditsBtn_pressed():
	add_child(credits_scene.instance())

func _on_ExitBtn_pressed():
	$ConfirmationDialog.popup()

func _on_ConfirmationDialog_confirmed():
	get_tree().quit()

func _on_button_mouse_entered():
	$AudioStreamPlayer.play()

func _on_button_mouse_exited():
	pass
