extends Node2D

onready var enemies_container = $Enemies
onready var spawn_points_container = $SpawnPoints
onready var player = $Player
onready var camera = $Camera2D
onready var defenses = $Defenses
onready var bullets = $Bullets
onready var nav_2d = $Map/Navigation2D

const enemy = preload("res://enemy.tscn")
const bullet = preload("res://bullet.tscn")
const pickable_obj = preload("res://pickableObject.tscn")

const hard_words_url = "res://words_alpha.txt"
const easy_words_url = "res://words_3000.txt"

const MAX_CAMERA_LEANING = 1.5

var active_enemy = null
var curr_letter_idx: int = -1

var enemy_number = 6
var text

var wave_number = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	text = load_text_file(easy_words_url)
	text = convert_to_array(text)
	text = remove_small_text(text)
	
	spawn_enemies()
			
	player.get_node("DangerArea").connect("body_entered", self, "on_dangerArea_body_entered")
	player.get_node("GameOverArea").connect("body_entered", self, "on_gameOverArea_body_entered")

func spawn_enemies():
	var spawn_points = spawn_points_container.get_children()
	
	for i in enemy_number:
		var enemy_instance = enemy.instance()
		var idx = randi() % spawn_points.size()
		enemies_container.add_child(enemy_instance)
		enemy_instance.global_position = spawn_points[idx].global_position
		enemy_instance.set_target(player)
		enemy_instance.set_prompt(text[int(rand_range(0.0, text.size()))])
		
		# Set path for enemy
		enemy_instance.path = nav_2d.get_simple_path(enemy_instance.global_position, player.global_position)
		
		# TEST: to remove
		$Dictionary.request(enemy_instance.get_prompt())
	

func _physics_process(delta):
	for enemy in enemies_container.get_children():
		pass
		#enemy.look_at(player.global_transform.origin)
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# TEST: To remove
		if Input.is_action_pressed("left_click"):
			pass
#			print("Enemy: %s , mouse: %s", [$Enemy.global_position, get_global_mouse_position()])
#			var points = nav_2d.get_simple_path($Enemy.global_position, get_global_mouse_position())
#			print(points)
#			$Line2D.points = points
	
	if event is InputEventKey and not event.is_pressed():
		var typed_event = event as InputEventKey
		
		if typed_event.scancode == KEY_BACKSPACE:
			print("deselect")
			curr_letter_idx = -1
			active_enemy.deselect()
			active_enemy = null
			reset_lean_camera()
			
		elif typed_event.scancode == KEY_ESCAPE:
			$CanvasLayer/PauseMenu.visible = true
		
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:
			var prompt = active_enemy.get_prompt()
			var next_char = prompt.substr(curr_letter_idx, 1)
			if key_typed == next_char:
				print("successfuly type %s" % key_typed)
				curr_letter_idx += 1
				active_enemy.set_next_character(curr_letter_idx)
				active_enemy.correctly_type()
				$SFX/GoodTypingSound.play()
				camera.shake(0.3, 25, 5)
				
				fire_bullet(player, active_enemy, key_typed)
				
				if curr_letter_idx == prompt.length():
					print("done")
					curr_letter_idx = -1
					get_tree().paused = true
					$FreezeTimer.start()
			else:
				print("incorrectly type %s instead of %s" % [key_typed, next_char])
				player.emit_lost_letter(key_typed)
				$SFX/TypingErrorSound.play()
				camera.shake(0.5, 50, 20)
	
func fire_bullet(shooter, target, letter):
	var bullet_instance = bullet.instance()
	bullets.add_child(bullet_instance)
	bullet_instance.start(shooter.global_transform, letter, target)
				
func lean_camera_towards(what):
	var lean_vector = Vector2(0.0, 0.0)
	lean_vector = what.global_transform.origin - (camera.global_transform.origin + camera.offset)
	lean_vector = lean_vector.normalized()
	camera.offset_h = lean_vector.x * MAX_CAMERA_LEANING
	camera.offset_v = lean_vector.y * MAX_CAMERA_LEANING
	camera.zoom -= Vector2(0.15, 0.15)
	
func reset_lean_camera():
	camera.offset_h = 0.0
	camera.offset_v = 0.0
	camera.zoom += Vector2(0.15, 0.15)
		
func find_new_active_enemy(typed_character: String):
	for enemy in enemies_container.get_children():
		var prompt = enemy.get_prompt()
		var next_char = prompt.substr(0, 1)
		if prompt.substr(0, 1) == typed_character:
			print("found new enemy that starts with %s" % next_char)
			active_enemy = enemy
			curr_letter_idx = 1
			lean_camera_towards(active_enemy)
			active_enemy.set_next_character(curr_letter_idx)
			active_enemy.select()
			
			fire_bullet(player, active_enemy, next_char)
			active_enemy.correctly_type()
			$SFX/GoodTypingSound.play()
			camera.shake(0.3, 25, 5)
			
			return
		
func check_enemy_number():
	return enemies_container.get_child_count()
	
func next_wave():
	wave_number += 1
		
func load_text_file(path):
	var f = File.new()
	var err = f.open(path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var text = f.get_as_text()
	f.close()
	return text

func convert_to_array(text):
	return text.split("\n", true)

func remove_small_text(text):
	var text_cleaned = Array()
	for word in text:
		if word.length() > 3:
			text_cleaned.append(word)
			
	return text_cleaned

func on_dangerArea_body_entered(body):
	if body.has_method('is_enemy'):
		body.danger()
		# TODO: add sfx

func on_gameOverArea_body_entered(body):
	$Tween.interpolate_property(camera, "zoom", camera.zoom, Vector2(0.7, 0.7), 0.8, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()
	Engine.time_scale = 0.25
	$CanvasLayer/GameOver.visible = true
	print("Game over")
	# TODO: game over screen + restart

func _on_GUI_picked_from_inventory(object_type):
	# Temporary, just to be able to click the button to place definitely
	var instance = pickable_obj.instance()
	instance.init(object_type)
	$CanvasLayer.add_child(instance)
	instance.connect("place", self, "on_place_defense")
	
func on_place_defense(who):
	$CanvasLayer.remove_child(who)
	defenses.add_child(who)
	who.connect("attack", self, "on_defense_attack")
	
func on_defense_attack(defense_obj, who, letter):
	fire_bullet(defense_obj, who, letter)

func _on_FreezeTimer_timeout():
	get_tree().paused = false
	active_enemy.correctly_type()
	$SFX/GoodTypingSound.play()
	$AnimationPlayer.play("shockwave")
	if active_enemy.has_collectable():
		Inventory.add_inventory(active_enemy.collectable)
		$CanvasLayer/GUI.update_inventory()
	active_enemy.queue_free()
	active_enemy = null
	reset_lean_camera()
	if check_enemy_number() == 0:
		next_wave()
