extends Node2D

# IMPORTANT we make the root node2D to be able to have the viewport closer to the root. 
# Viewport must be instantiate first when creating the tree, otherwise it will thorw an
# error 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func start():
	$Particles.emitting = true
	$Particles/EmissionFinishedTimer.wait_time = $Particles.lifetime
	$Particles/EmissionFinishedTimer.start()

func set_letter(letter):
	$Viewport/Letter.text = str(letter)

func _on_EmissionFinishedTimer_timeout():
	queue_free()
