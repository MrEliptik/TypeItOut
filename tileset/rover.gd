extends Node2D

export var sprite = "res://sprites/floor_details/rover_NE.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.texture = load(sprite)
	$AnimationPlayer.play("work")

