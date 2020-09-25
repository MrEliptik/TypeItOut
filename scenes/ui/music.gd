extends Node2D

onready var audio_master = AudioServer.get_bus_channels(AudioServer.get_bus_index("Master"))
onready var master_idx = AudioServer.get_bus_index("Master")

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().paused:
		# Muffle music
		AudioServer.set_bus_volume_db(master_idx, AudioServer.get_bus_volume_db(master_idx) - 10.0)

func is_playing():
	return $Music.playing

func play():
	$Music.play()

func stop():
	$Music.stop()
