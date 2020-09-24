extends Control

signal picked_from_inventory(object_type)

const arrow = preload("res://sprites/ui/cursor_pointer3D.png")
const hand = preload("res://sprites/ui/cursor_hand.png")

const pickable = preload("res://pickableObject.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	update_inventory()
	
func _process(delta):
	set_time_left($InBetweenWaveTimer.time_left)
	
func update_inventory():
	for i in range(Inventory.inventory_size):
		# Clear first
		$HBoxContainer2.get_child(i).texture = null
		# Update where needed
		if i < Inventory.inventory.size():
			$HBoxContainer2.get_child(i).texture = load(Inventory.type_Sprite[Inventory.inventory[i]])
			
func start_wave_finished(number, data):
	get_parent().get_node("Vignette").visible = true
	$ShowFinishedTimer.start()
	$InBetweenWaveTimer.start()
	$WaveFinished/Label.text = "WAVE " + str(number) + " FINISHED!"
	$AnimationPlayer.play("wave_finished")
	display_data(data)
	$StatsContainer.visible = true
	$TimerContainer.visible = true

func hide_wave_finished():
	$WaveFinished.visible = false
	$StatsContainer.visible = false
	#$TimerContainer.visible = false	
	get_parent().get_node("Vignette").visible = false
	
func start_place():
	$AnimationPlayer.play("place")
	toggle_hide_inventory()
	
func start_wave(number):
	$TimerContainer.visible = false
	$WaveStart/Label.text = "WAVE " + str(number) + " START!"
	$AnimationPlayer.play("wave_start")
	toggle_hide_inventory()

func toggle_hide_inventory():
	$HBoxContainer.visible = !$HBoxContainer.visible
	$HBoxContainer2.visible = !$HBoxContainer2.visible
	
func display_data(data):
	$StatsContainer/EnemiesKillerContainer/Value.text = str(data["enemies"])
	$StatsContainer/ErrorsContainer/Value.text = str(data["errors"])
	$StatsContainer/WordTimeContainer/Value.text = str(stepify(data["word_time"], 0.1))
	
func set_time_left(time):
	$TimerContainer/NextWaveTime.text = str(stepify(time, 1))

func _on_TextureButton_pressed():
	if !visible: return
	var item = Inventory.get_item(0)
	if item == null: return
	emit_signal("picked_from_inventory", Inventory.inventory[0])

func _on_TextureButton2_pressed():
	if !visible: return
	var item = Inventory.get_item(1)
	if item == null: return
	emit_signal("picked_from_inventory", Inventory.inventory[1])

func _on_TextureButton3_pressed():
	if !visible: return
	var item = Inventory.get_item(2)
	if item == null: return
	emit_signal("picked_from_inventory", Inventory.inventory[2])

func _on_TextureButton4_pressed():
	if !visible: return
	var item = Inventory.get_item(3)
	if item == null: return
	emit_signal("picked_from_inventory", Inventory.inventory[3])

func _on_TextureButton5_pressed():
	if !visible: return
	var item = Inventory.get_item(3)
	if item == null: return
	emit_signal("picked_from_inventory", Inventory.inventory[4])

func _on_TextureButton_mouse_entered():
	if !visible: return
	Input.set_custom_mouse_cursor(hand)

func _on_TextureButton_mouse_exited():
	if !visible: return
	Input.set_custom_mouse_cursor(arrow)

func _on_ShowFinishedTimer_timeout():
	hide_wave_finished()
	start_place()

func _on_InBetweenWaveTimer_timeout():
	pass # Replace with function body.
