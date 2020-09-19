extends Node2D

enum TYPE{
	CATAPULT,
	ARROW
}

var type_sprite = {
	TYPE.CATAPULT : "res://sprites/weapon_catapult_E.png"
}

var type
# Until placed, follow the mouse position
var placed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if placed: return
	if Input.is_action_pressed("right_click"):
		# User cancel placement
		# TODO: notify inventory of cancelling
		cancel()
	elif Input.is_action_pressed("left_click"):
		place(get_global_mouse_position())
	global_position = get_global_mouse_position()

func init(type):
	# TODO replace sprite depending on what object
	self.type = type
	$Groupe/Sprite.texture = load(type_sprite[type])
	$Groupe/VBoxContainer.visible = false
	$AnimationPlayer.play("moving")
	
func place(where):
	placed = true
	global_position = where
	# TODO: animate visibility (boucny effect?)
	$Groupe/VBoxContainer.visible = true
	reset_pos()
	$AnimationPlayer.play("place")
	
func reset_pos():
	$Groupe/Sprite.scale = Vector2(1.0, 1.0)
	$Groupe/Sprite.rotation_degrees = 0
	$AnimationPlayer.stop()

func cancel():
	queue_free()

func _on_Yes_pressed():
	$Groupe/VBoxContainer.visible = false

func _on_No_pressed():
	$Groupe/VBoxContainer.visible = false
	placed = false
