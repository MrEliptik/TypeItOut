extends Particles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func start():
	emitting = true
	$EmissionFinishedTimer.wait_time = lifetime
	$EmissionFinishedTimer.start()

func _on_EmissionFinishedTimer_timeout():
	queue_free()
