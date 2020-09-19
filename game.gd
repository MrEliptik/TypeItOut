extends Node2D

onready var enemies = $Enemies
onready var player = $Player
onready var camera = $Camera2D

const enemy = preload("res://enemy.tscn")

var active_enemy = null
var curr_letter_idx: int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var text = load_text_file("res://words_alpha.txt")
	text = convert_to_array(text)
	text = remove_small_text(text)
	
	for enemy in enemies.get_children():
		enemy.set_target(player)
		enemy.set_prompt(text[int(rand_range(0.0, text.size()))])
		
	player.get_node("DangerArea").connect("body_entered", self, "on_dangerArea_body_entered")

func _physics_process(delta):
	for enemy in enemies.get_children():
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
				active_enemy.correctly_type()
				if curr_letter_idx == prompt.length():
					print("done")
					curr_letter_idx = -1
					active_enemy.queue_free()
					active_enemy = null
			else:
				print("incorrectly type %s instead of %s" % [key_typed, next_char])
				camera.shake(0.5, 50, 20)
		
func find_new_active_enemy(typed_character: String):
	for enemy in enemies.get_children():
		var prompt = enemy.get_prompt()
		var next_char = prompt.substr(0, 1)
		if prompt.substr(0, 1) == typed_character:
			print("found new enemy that starts with %s" % next_char)
			active_enemy = enemy
			curr_letter_idx = 1
			print("new enemy")
			enemy.selected()
		
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
