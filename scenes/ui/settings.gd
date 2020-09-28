extends Control

enum WINDOW_TYPE {
	FULLSCREEN,
	BORDERLESS,
	NORMAL
}

var windows_type_str = {
	WINDOW_TYPE.FULLSCREEN : "Fullscreen",
	WINDOW_TYPE.BORDERLESS : "Borderless",
	WINDOW_TYPE.NORMAL : "Windowed"
}

var windows_size = [Vector2(2560, 1440),Vector2(1920, 1080),Vector2(1600, 900),Vector2(1366, 768),Vector2(1280, 720),Vector2(960, 540)]

var windows_size_str = {
	"2560x1440" : Vector2(2560, 1440),
	"1920x1080" : Vector2(1920, 1080),
	"1600x900" : Vector2(1600, 900),
	"1366x768" : Vector2(1366, 768),
	"1280x720" : Vector2(1280, 720),
	"960x540" : Vector2(960, 540)
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$SettingsContainer/VolumeContainer/GeneralContainer/GeneralSlider.value = int(db2linear(Music.get_volume())*100)
	$SettingsContainer/VolumeContainer/MusicContainer/MusicSlider.value = int(db2linear(Music.get_music_volume())*100)
	$SettingsContainer/VolumeContainer/EffectContainer/EffectSlider.value = int(db2linear(Music.get_effects_volume())*100)
	$SettingsContainer/VolumeContainer/GeneralContainer/GeneralToggle.pressed = !Music.is_master_mute()
	$SettingsContainer/VolumeContainer/MusicContainer/MusicToggle.pressed = !Music.is_music_mute()
	$SettingsContainer/VolumeContainer/EffectContainer/EffectToggle.pressed = !Music.is_effects_mute()

	for resolution in windows_size_str.keys():
		$SettingsContainer/DisplayContainer/ResolutionContainer/ResolutionOptions.add_item(resolution)
	
	for option in windows_type_str.keys():
		$SettingsContainer/DisplayContainer/WindowTypeContainer/WindowTypeOptions.add_item(windows_type_str[option])
		
	$SettingsContainer/DisplayContainer/ResolutionContainer/ResolutionOptions.selected = 1

########################## MUSIC ####################################
func _on_GeneralSlider_value_changed(value):
	$SettingsContainer/VolumeContainer/GeneralContainer/Value.text = str(value)
	Music.set_volume(linear2db(value/100))

func _on_MusicSlider_value_changed(value):
	$SettingsContainer/VolumeContainer/MusicContainer/Value.text = str(value)
	Music.set_music_volume(linear2db(value/100))
	
func _on_EffectSlider_value_changed(value):
	$SettingsContainer/VolumeContainer/EffectContainer/Value.text = str(value)
	#db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))*100
	Music.set_effects_volume(linear2db(value/100))
	
func _on_GeneralToggle_toggled(button_pressed):
	Music.toggle_master_mute(!button_pressed)

func _on_MusicToggle_toggled(button_pressed):
	Music.toggle_music_mute(!button_pressed)

func _on_EffectToggle_toggled(button_pressed):
	Music.toggle_effects_mute(!button_pressed)


########################## DISPLAY ####################################
func _on_ResolutionOptions_item_selected(index):
	OS.set_window_size(windows_size[index])

func _on_WindowTypeOptions_item_selected(index):
	if index == WINDOW_TYPE.FULLSCREEN:
		OS.window_fullscreen = true
		OS.window_borderless = true
	elif index == WINDOW_TYPE.BORDERLESS:
		OS.window_fullscreen = false
		OS.window_borderless = true
	elif index == WINDOW_TYPE.NORMAL:
		OS.window_fullscreen = false
		OS.window_borderless = false

func _on_VSyncToggle_toggled(button_pressed):
	OS.vsync_enabled = button_pressed

func _on_HomeBtn_pressed():
	visible = false
	queue_free()
