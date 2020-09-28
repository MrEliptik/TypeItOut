extends Node2D

onready var audio_master = AudioServer.get_bus_channels(AudioServer.get_bus_index("Master"))
onready var master_idx = AudioServer.get_bus_index("Master")
onready var music_idx = AudioServer.get_bus_index("Music")
onready var effect_idx = AudioServer.get_bus_index("Effect")

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().paused:
		# Muffle music
		AudioServer.set_bus_volume_db(master_idx, get_volume() - 10.0)

func is_playing():
	return $Music.playing

func play():
	$Music.play()

func stop():
	$Music.stop()
	
func get_volume():
	return AudioServer.get_bus_volume_db(master_idx)

func get_music_volume():
	return AudioServer.get_bus_volume_db(music_idx)

func get_effects_volume():
	return AudioServer.get_bus_volume_db(effect_idx)

func is_master_mute():
	return AudioServer.is_bus_mute(master_idx)

func is_music_mute():
	return AudioServer.is_bus_mute(music_idx)

func is_effects_mute():
	return AudioServer.is_bus_mute(effect_idx)

func set_volume(value):
	AudioServer.set_bus_volume_db(master_idx, value)

func set_music_volume(value):
	AudioServer.set_bus_volume_db(music_idx, value)
	
func set_effects_volume(value):
	AudioServer.set_bus_volume_db(effect_idx, value)

func toggle_master_mute(btn):
	AudioServer.set_bus_mute(master_idx, btn)

func toggle_music_mute(btn):
	AudioServer.set_bus_mute(music_idx, btn)

func toggle_effects_mute(btn):
	AudioServer.set_bus_mute(effect_idx, btn)
