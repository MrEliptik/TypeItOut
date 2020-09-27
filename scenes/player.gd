extends KinematicBody2D

const lost_letter = preload("res://scenes/effects/lostLetter.tscn")


var curr_enemy = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if curr_enemy:
		pass
		#orient_torward(curr_enemy.get_position())
	
func look_at_enemey(enemy):
	curr_enemy = enemy
	
func orient_torward(what):
	rad2deg(global_position.angle_to(curr_enemy.get_position()))

func emit_lost_letter(letter):
	var instance = lost_letter.instance()
	add_child(instance)
	instance.set_letter(letter)
	instance.start()

