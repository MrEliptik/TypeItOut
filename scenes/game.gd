extends Node2D

onready var enemies_container = $Enemies
onready var spawn_points_container = $SpawnPoints
onready var player = $Player
onready var camera = $Camera2D
onready var defenses = $Defenses
onready var bullets = $Bullets
onready var nav_2d = $Map/Navigation2D

const enemy = preload("res://scenes/enemy.tscn")
const bullet = preload("res://scenes/effects/bullet.tscn")
const pickable_obj = preload("res://scenes/pickableObject.tscn")
const letter_particle = preload("res://scenes/effects/lostLetter.tscn")
const collectable_bullet = preload("res://scenes/effects/collectableBullet.tscn")

const hard_words_url = "res://words_alpha.txt"
const easy_words_url = "res://words_3000.txt"

const MAX_CAMERA_LEANING = 1.5

var active_enemy = null
var curr_letter_idx: int = -1

var text

var wave_number = 1
var enemy_number = 6
var enemy_speed = 35.0

var enemy_speed_increment = 5

var in_between_wave = false

onready var game_over = false

var inventory_to_remove = null

var defense_placeable = true

var not_started = true

var data = {
	"wave":0,
	"errors": 0,
	"enemies": 0,
	"word_time":0,
	"errors_total":0,
	"enemies_total":0,
	"word_time_total":0,
}

var start_word_time

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	if !Music.is_playing():
		Music.play()
	
	text = load_text_file(easy_words_url)
	text = convert_to_array(text)
	text = remove_small_text(text)
	
	$AnimationPlayer.play("enemy_appearance")
			
	player.get_node("DangerArea").connect("area_entered", self, "on_dangerArea_body_entered")
	player.get_node("GameOverArea").connect("area_entered", self, "on_gameOverArea_body_entered")
	
	$CanvasLayer/GUI/StartBtn.connect("pressed", self, "on_gui_start_btn_pressed")

func spawn_enemies_with_animation():
	var at_least_one_turret = false
	var spawn_points = [$SpawnPoints/Node2D3, $SpawnPoints/Node2D4, $SpawnPoints/Node2D5, $SpawnPoints/Node2D6, $SpawnPoints/Node2D10, $SpawnPoints/Node2D11, $SpawnPoints/Node2D14]
	
	for i in enemy_number:
		var enemy_instance = enemy.instance()
		enemies_container.add_child(enemy_instance)
		enemy_instance.global_position = spawn_points[i].global_position
		enemy_instance.set_target(player)
		
		var txt = text[int(rand_range(0.0, text.size()))]
		var same_starting_letter = false
		# We loop through enemies to see if another has the same
		# starting letter
		for enemy in enemies_container.get_children():
			# If we find one, we stop
			if enemy.get_prompt().substr(0, 1) == txt.substr(0,1):
				same_starting_letter = true
				break
		while(same_starting_letter):
			txt = text[int(rand_range(0.0, text.size()))]
			same_starting_letter = false
			# We loop through enemies to see if another has the same
			# starting letter
			for enemy in enemies_container.get_children():
				# If we find one, we stop
				if enemy.get_prompt().substr(0, 1) == txt.substr(0,1):
					same_starting_letter = true
					break
			
		enemy_instance.set_prompt(txt)
		enemy_instance.set_speed(enemy_speed)
		if enemy_instance.collectable: at_least_one_turret = true
		
		# Set path for enemy
		enemy_instance.path = nav_2d.get_simple_path(enemy_instance.global_position, player.global_position)
		
		$Dictionary.clear_queue()
		$Dictionary.add_to_queue(enemy_instance.get_prompt())
	$Dictionary.request_queue()
	
	# We want at least one turret on the first level
	if wave_number == 1:
		if at_least_one_turret: return
	# We give a double turret
	enemies_container.get_child(0).set_collectable(1)

func spawn_enemies():
	var at_least_one_turret = false
	
	var spawn_points = spawn_points_container.get_children()
	
	for i in enemy_number:
		var enemy_instance = enemy.instance()
		var idx = randi() % spawn_points.size()
		enemies_container.add_child(enemy_instance)
		enemy_instance.global_position = spawn_points[idx].global_position
		enemy_instance.set_target(player)
		
		var txt = text[int(rand_range(0.0, text.size()))]
		var same_starting_letter = false
		# We loop through enemies to see if another has the same
		# starting letter
		for enemy in enemies_container.get_children():
			# If we find one, we stop
			if enemy.get_prompt().substr(0, 1) == txt.substr(0,1):
				same_starting_letter = true
				break
		while(same_starting_letter):
			txt = text[int(rand_range(0.0, text.size()))]
			same_starting_letter = false
			# We loop through enemies to see if another has the same
			# starting letter
			for enemy in enemies_container.get_children():
				# If we find one, we stop
				if enemy.get_prompt().substr(0, 1) == txt.substr(0,1):
					same_starting_letter = true
					break
			
		enemy_instance.set_prompt(txt)
		enemy_instance.set_speed(enemy_speed)
		if enemy_instance.collectable: at_least_one_turret = true
		
		# Set path for enemy
		enemy_instance.path = nav_2d.get_simple_path(enemy_instance.global_position, player.global_position)
		
		$Dictionary.clear_queue()
		$Dictionary.add_to_queue(enemy_instance.get_prompt())
	$Dictionary.request_queue()
	
	# We want at least one turret on the first level
	if wave_number == 1:
		if at_least_one_turret: return
	# We give a double turret
	enemies_container.get_child(0).set_collectable(1)
	
func _process(delta):
	if game_over or not_started: return
	if check_enemy_number() == 0 && !in_between_wave:
		in_between_wave = true
		next_wave()
	if Input.is_action_just_pressed("ui_cancel"):
		pass
		#$CanvasLayer/PauseMenu.visible = true

func _physics_process(delta):
	pass
		
func _unhandled_input(event: InputEvent) -> void:
	if not_started: return
	# Check event pressed because we don't see the event as being not pressed on windaube
	if event is InputEventKey and event.is_pressed():
		if game_over: return
		var typed_event = event as InputEventKey
		
		if typed_event.scancode == KEY_BACKSPACE && active_enemy:
			print("deselect")
			curr_letter_idx = -1
			active_enemy.deselect()
			active_enemy = null
			reset_lean_camera()
			
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:
			var prompt = active_enemy.get_prompt()
			var next_char = prompt.substr(curr_letter_idx, 1)
			if key_typed == next_char:
				print("successfuly type %s" % key_typed)
				curr_letter_idx += 1
				active_enemy._curr_char_idx += 1
				active_enemy.set_next_character(curr_letter_idx)
				active_enemy.correctly_type()
				enemy_correctly_typed(active_enemy, key_typed)
				$SFX/GoodTypingSound.play()
				camera.shake(0.1, 25, 5)			
				fire_bullet(player, active_enemy.get_node("Enemy"), key_typed)
				
				if curr_letter_idx == prompt.length():
					print("done")
					curr_letter_idx = -1
					data["enemies"] += 1
					data["enemies_total"] += 1
					
					calculate_wpm(OS.get_ticks_msec() - start_word_time, prompt)
					$AnimationPlayer.play("shockwave")
					if active_enemy.has_collectable():
						Inventory.add_inventory(active_enemy.collectable)
						collect_collectable(active_enemy, player, active_enemy.collectable)
						$CanvasLayer/GUI.update_inventory()
					active_enemy.die()
					active_enemy = null
					reset_lean_camera()
			else:
				print("incorrectly type %s instead of %s" % [key_typed, next_char])
				player.emit_lost_letter(key_typed)
				$SFX/TypingErrorSound.play()
				camera.shake(0.5, 50, 15)
				data["errors"] += 1
				data["errors_total"] += 1
	
func enemy_correctly_typed(who, letter):
	var instance = letter_particle.instance()
	add_child(instance)
	instance.set_letter(letter)
	instance.global_position = who.get_position()
	instance.start()

func fire_bullet(shooter, target, letter):
	var bullet_instance = bullet.instance()
	bullets.add_child(bullet_instance)
	bullet_instance.start(shooter, letter, target)
	
func collect_collectable(shooter, target, type):
	var instance = collectable_bullet.instance()
	bullets.add_child(instance)
	instance.start(shooter, type, target)
				
func lean_camera_towards(what):
	var lean_vector = Vector2(0.0, 0.0)
	lean_vector = what.get_position() - (camera.global_transform.origin + camera.offset)
	lean_vector = lean_vector.normalized()
	camera.offset_h = lean_vector.x * MAX_CAMERA_LEANING
	camera.offset_v = lean_vector.y * MAX_CAMERA_LEANING
	camera.zoom = Vector2(0.95, 0.95)
	
func reset_lean_camera():
	camera.offset_h = 0.0
	camera.offset_v = 0.0
	camera.zoom = Vector2(1.1, 1.1)
		
func find_new_active_enemy(typed_character: String):
	# Initial distance must be huge for the first
	# enemy to be selected
	var min_distance = 100000000
	for enemy in enemies_container.get_children():
		var prompt = enemy.get_prompt()
		var next_char
		# Enemy has already been typed
		if enemy._curr_char_idx != -1:
			next_char = prompt.substr(enemy._curr_char_idx, 1)
			print(next_char)
		else:
			next_char = prompt.substr(0, 1)
		if next_char == typed_character:
			print("found new enemy that starts with %s" % next_char)
			var dist = enemy.get_position().distance_to(player.global_position)
			if dist < min_distance:
				active_enemy = enemy
	
	# A typed character that doesn't match anyone
	if !active_enemy: return
	
	player.look_at_enemey(active_enemy)
	# We selected the closest enemy that starts with the typed_char
	start_word_time = OS.get_ticks_msec()
	var next_char
	# Enemy has already been typed
	if active_enemy._curr_char_idx != -1:
		active_enemy._curr_char_idx += 1
		curr_letter_idx = active_enemy._curr_char_idx
		next_char = active_enemy.get_prompt().substr(active_enemy._curr_char_idx, 1)
		
		# If we attack the enemy on its last letter (the rest has been done by the turret)
		if curr_letter_idx == active_enemy.get_prompt().length():
			print("done")
			curr_letter_idx = -1
			data["enemies"] += 1
			data["enemies_total"] += 1
			
			$AnimationPlayer.play("shockwave")
			if active_enemy.has_collectable():
				Inventory.add_inventory(active_enemy.collectable)
				$CanvasLayer/GUI.update_inventory()
				collect_collectable(active_enemy, player, active_enemy.collectable)
			active_enemy.die()
			active_enemy = null
			reset_lean_camera()
			return
	else:
		next_char = active_enemy.get_prompt().substr(0, 1)
		active_enemy._curr_char_idx = 1
		curr_letter_idx = 1
	
	if !active_enemy: return
	lean_camera_towards(active_enemy)
	active_enemy.set_next_character(curr_letter_idx)
	active_enemy.select()
	
	fire_bullet(player, active_enemy.get_node("Enemy"), next_char)
	active_enemy.correctly_type()
	$SFX/GoodTypingSound.play()
	camera.shake(0.3, 25, 5)
		
func check_enemy_number():
	return enemies_container.get_child_count()
	
func next_wave():	
	# Display collected data (errors, wpm ?)
	$CanvasLayer/GUI.start_wave_finished(wave_number, data)
	
	wave_number += 1
	data["wave"] += 1
	# Make number of enemies and speed increase
	enemy_speed += enemy_speed_increment
	# If wave nubmer is pair, we add 1 enemy
	if wave_number % 2 == 0: 
		enemy_number += 1
	reset_data()
	
	# Launch timer
	$InBetweenWaveTimer.start()
	
func reset_data():
	data["enemies"] = 0
	data["errors"] = 0
	data["word_time"] = 0
	
func calculate_wpm(time, word):
	data["word_time"] += time 
	data["word_time"] /= 2
	data["word_time_total"] += data["word_time"]
	data["word_time_total"] /= 2
		
func load_text_file(path):
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var txt = f.get_as_text()
	f.close()
	return txt

func convert_to_array(value):
	return value.split("\n", true)

func remove_small_text(value):
	var text_cleaned = Array()
	for word in value:
		if word.length() > 3:
			text_cleaned.append(word)
			
	return text_cleaned

func on_dangerArea_body_entered(area):
	if area.get_parent().has_method('is_enemy'):
		area.get_parent().danger()
		# TODO: add sfx

func on_gameOverArea_body_entered(area):
	if area.get_parent().has_method('is_enemy'):
		if game_over: return
		reset_lean_camera()
		stop_rover_sound()
		$SFX/Environment/Drill.stop()
		Music.stop()
		$SFX/Music/GameOver.play()
		$Tween.interpolate_property(camera, "zoom", camera.zoom, Vector2(0.7, 0.7), 0.8, Tween.TRANS_EXPO, Tween.EASE_OUT)
		$Tween.start()
		player.get_node("AnimationPlayer").play("die")
		Engine.time_scale = 0.25
		$CanvasLayer/GameOver.visible = true
		$"CanvasLayer/GameOver".display_data(data)
		game_over = true
		print("Game over")
		
func stop_rover_sound():
	for rover in $Map/Navigation2D/TileMap/Rovers.get_children():
		rover.get_node("EngineSound").stop()

func _on_GUI_picked_from_inventory(object_type):
	if !defense_placeable: return
	defense_placeable = false
	# Temporary, just to be able to click the button to place definitely
	var instance = pickable_obj.instance()
	instance.init(object_type)
	$CanvasLayer.add_child(instance)
	instance.connect("place", self, "on_place_defense")
	instance.connect("cancel", self, "on_cancel_defense")
	instance.connect("cancel_place", self, "on_cancel_place_defense")
	
func on_cancel_place_defense(who):
	defense_placeable = false
	
func on_cancel_defense(who):
	defense_placeable = true
	
func on_place_defense(who, type, where):
	defense_placeable = true
	$CanvasLayer.remove_child(who)
	defenses.add_child(who)
	who.global_position = where
	Inventory.remove_inventory(type)
	$CanvasLayer/GUI.update_inventory()
	who.connect("attack", self, "on_defense_attack")
	
func on_defense_attack(defense_obj, what):
	var prompt = what.get_prompt()
	var letter = null
	if what == active_enemy:
		letter = prompt.substr(curr_letter_idx, 1)
		curr_letter_idx += 1
		what._curr_char_idx += 1
		what.set_next_character(what._curr_char_idx)
		what.correctly_type()
		print("Defense launched: %s" % letter)
		fire_bullet(defense_obj, what.get_node("Enemy"), letter)
		enemy_correctly_typed(what, letter)
		
		if curr_letter_idx == prompt.length():
			print("done")
			curr_letter_idx = -1
			data["enemies"] += 1
			data["enemies_total"] += 1
			defense_obj.target.erase(what)
			
			if what.has_collectable():
				Inventory.add_inventory(what.collectable)
				$CanvasLayer/GUI.update_inventory()
			what.die()
			reset_lean_camera()
	else:
		if what._curr_char_idx == -1: what._curr_char_idx = 0
		letter = prompt.substr(what._curr_char_idx, 1)
		
		what._curr_char_idx += 1
		what.set_next_character(what._curr_char_idx)
		what.correctly_type()
		print("Defense launched: %s" % letter)
		fire_bullet(defense_obj, what.get_node("Enemy"), letter)
		enemy_correctly_typed(what, letter)
		
		if what._curr_char_idx == prompt.length():
			print("done")
			data["enemies"] += 1
			data["enemies_total"] += 1
			
			if what.has_collectable():
				Inventory.add_inventory(what.collectable)
				$CanvasLayer/GUI.update_inventory()
			what.die()

func _on_InBetweenWaveTimer_timeout():
	$CanvasLayer/GUI.start_wave(wave_number)
	# Start next wave
	spawn_enemies()
	in_between_wave = false
	
func on_gui_start_btn_pressed():
	$InBetweenWaveTimer.stop()
	$CanvasLayer/GUI.start_wave(wave_number)
	# Start next wave
	spawn_enemies()
	in_between_wave = false


func _on_AnimationPlayer_animation_finished(anim_name):
	not_started = false
