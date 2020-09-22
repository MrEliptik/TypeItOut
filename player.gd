extends KinematicBody2D

const lost_letter = preload("res://lostLetter.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func emit_lost_letter(letter):
	var instance = lost_letter.instance()
	add_child(instance)
	instance.set_letter(letter)
	instance.start()
	
