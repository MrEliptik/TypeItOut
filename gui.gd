extends Control

signal picked_from_inventory(object)

const arrow = preload("res://sprites/ui/cursor_pointer3D.png")
const hand = preload("res://sprites/ui/cursor_hand.png")

const pickable = preload("res://pickableObject.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var pickable_instance = pickable.instance()
	Inventory.inventory.append(pickable_instance)
	pickable_instance.init(pickable_instance.TYPE.CATAPULT)


func _on_TextureButton_pressed():
	if Inventory.inventory[0]:
		print(Inventory.inventory[0])
		emit_signal("picked_from_inventory", Inventory.inventory[0])

func _on_TextureButton2_pressed():
	pass # Replace with function body.


func _on_TextureButton3_pressed():
	pass # Replace with function body.


func _on_TextureButton4_pressed():
	pass # Replace with function body.


func _on_TextureButton5_pressed():
	pass # Replace with function body.


func _on_TextureButton_mouse_entered():
	Input.set_custom_mouse_cursor(hand)

func _on_TextureButton_mouse_exited():
	Input.set_custom_mouse_cursor(arrow)
