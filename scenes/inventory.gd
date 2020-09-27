extends Node

enum TYPE{
	SINGLE_TURRET=0,
	DOUBLE_TURRET=1
}

var type_AnimatedSprite = {
	TYPE.SINGLE_TURRET : "res://sprites/defenses/turret_single.tres",
	TYPE.DOUBLE_TURRET : "res://sprites/defenses/turret_double.tres"
}

var type_Sprite = {
	TYPE.SINGLE_TURRET : "res://sprites/defenses/turret_single_SE.png",
	TYPE.DOUBLE_TURRET : "res://sprites/defenses/turret_double_SE.png"
}

var inventory = Array()
var inventory_size = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_inventory(collectable):
	if inventory.size() < inventory_size:
		inventory.append(collectable)
		
func remove_inventory(collectable):
	inventory.erase(collectable)
	
func get_item(idx):
	if idx < inventory.size():
		return inventory[idx]
	else: return null
	
func clear_inventory():
	inventory = Array()
