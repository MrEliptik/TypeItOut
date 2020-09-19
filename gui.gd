extends Control

const arrow = preload("res://sprites/ui/cursor_pointer3D.png")
const hand = preload("res://sprites/ui/cursor_hand.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_mouse_entered():
	Input.set_custom_mouse_cursor(hand)


func _on_Button_mouse_exited():
	Input.set_custom_mouse_cursor(arrow)


func _on_Button_pressed():
	pass # Replace with function body.


func _on_Button2_pressed():
	pass # Replace with function body.


func _on_Button3_pressed():
	pass # Replace with function body.


func _on_Button4_pressed():
	pass # Replace with function body.


func _on_Button5_pressed():
	pass # Replace with function body.
