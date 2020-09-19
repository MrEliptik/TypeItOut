extends Node2D

onready var enemies_container = $Enemies
onready var spawn_points_container = $SpawnPoints
onready var player = $Player
onready var camera = $Camera2D
onready var defenses = $Defenses

const enemy = preload("res://enemy.tscn")

const MAX_CAMERA_LEANING = 1.0

var active_enemy = null
var curr_letter_idx: int = -1

var enemy_number = 5
var text

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	text = load_text_file("res://words_alpha.txt")
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
	

func _physics_process(delta):
	for enemy in enemies_container.get_children():
		pass
		#enemy.look_at(player.global_transform.origin)
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and not event.is_pressed():
		var typed_event = event as InputEventKey
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
				if curr_letter_idx == prompt.length():
					print("done")
					curr_letter_idx = -1
					$AnimationPlayer.play("shockwave")
					active_enemy.queue_free()
					active_enemy = null
					reset_lean_camera()
			else:
				print("incorrectly type %s instead of %s" % [key_typed, next_char])
				camera.shake(0.5, 50, 20)
				
func lean_camera_towards(what):
	var lean_vector = Vector2(0.0, 0.0)
	lean_vector = (what.global_transform.origin - camera.global_transform.origin).normalized()
	camera.offset_h = lean_vector.x * MAX_CAMERA_LEANING
	camera.offset_v = lean_vector.y * MAX_CAMERA_LEANING
	
func reset_lean_camera():
	camera.offset_h = 0.0
	camera.offset_v = 0.0
		
func find_new_active_enemy(typed_character: String):
	for enemy in enemies_container.get_children():
		var prompt = enemy.get_prompt()
		var next_char = prompt.substr(0, 1)
		if prompt.substr(0, 1) == typed_character:
			print("found new enemy that starts with %s" % next_char)
			active_enemy = enemy
			curr_letter_idx = 1
			active_enemy.set_next_character(curr_letter_idx)
			active_enemy.selected()
			lean_camera_towards(active_enemy)
			return
		
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
	print("Game over")
	# TODO: game over screen + restart

func _on_GUI_picked_from_inventory(object):
	defenses.add_child(object)
	#object.global_position = get_global_mouse_position()
