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
	
func get_volume():
	pass

func get_music_volume():
	pass

func get_effects_volume():
	pass

func is_master_mute():
	pass

func is_music_mute():
	pass

func is_effects_mute():
	pass

func set_volume(value):
	pass

func set_music_volume(value):
	pass
	
func set_effects_volume(value):
	pass

func toggle_master_mute(btn):
	pass

func toggle_music_mute(btn):
	pass

func toggle_effects_mute(btn):
	pass
