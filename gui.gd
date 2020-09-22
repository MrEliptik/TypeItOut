extends Control

signal picked_from_inventory(object_type)

const arrow = preload("res://sprites/ui/cursor_pointer3D.png")
const hand = preload("res://sprites/ui/cursor_hand.png")

const pickable = preload("res://pickableObject.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# TEST: to remove
	Inventory.inventory.append(Inventory.TYPE.DOUBLE_TURRET)
	Inventory.inventory.append(Inventory.TYPE.SINGLE_TURRET)
	update_inventory()
	
func update_inventory():
	for i in range(Inventory.inventory_size):
		# Clear first
		$HBoxContainer2.get_child(i).texture = null
		# Update where needed
		if i < Inventory.inventory.size():
			$HBoxContainer2.get_child(i).texture = load(Inventory.type_Sprite[Inventory.inventory[i]])

func _on_TextureButton_pressed():
	var item = Inventory.get_item(0)
	if item == null: return
	emit_signal("picked_from_inventory", Inventory.inventory[0])

func _on_TextureButton2_pressed():
	var item = Inventory.get_item(1)
	if item == null: return
	emit_signal("picked_from_inventory", Inventory.inventory[1])

func _on_TextureButton3_pressed():
	var item = Inventory.get_item(2)
	if item == null: return
	emit_signal("picked_from_inventory", Inventory.inventory[2])

func _on_TextureButton4_pressed():
	var item = Inventory.get_item(3)
	if item == null: return
	emit_signal("picked_from_inventory", Inventory.inventory[3])

func _on_TextureButton5_pressed():
	var item = Inventory.get_item(3)
	if item == null: return
	emit_signal("picked_from_inventory", Inventory.inventory[4])

func _on_TextureButton_mouse_entered():
	Input.set_custom_mouse_cursor(hand)

func _on_TextureButton_mouse_exited():
	Input.set_custom_mouse_cursor(arrow)
