extends KinematicBody2D

export (Color) var blue = Color("#4682b4")
export (Color) var green = Color("#639765")
export (Color) var red = Color("#a65455")

const hit_particles = preload("res://hitEnemyParticles.tscn")
const letter_particle = preload("res://lostLetter.tscn")

onready var prompt = $Word
onready var prompt_text = prompt.text.to_lower()

var sprites = ["res://sprites/enemy/enemy_ufoGreen_E.png", "res://sprites/enemy/enemy_ufoPurple_E.png",
	"res://sprites/enemy/enemy_ufoRed_E.png", "res://sprites/enemy/enemy_ufoYellow_E.png"]

var speed = 50.0
var collectable_chance = 0.10

var curr_letter = null

var target = null
var path : = PoolVector2Array() setget set_path

var collectable = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_process(false)
	
	$Sprite.texture = load(sprites[int(rand_range(0, sprites.size()))])
	# Draw random item at 10% chance
	if(randf() < collectable_chance):
		var idx = int(rand_range(0, Inventory.type_Sprite.size()))
		collectable = idx
		
		var sprite = $Sprite/Collectable
		sprite.texture = load(Inventory.type_Sprite[idx])
		sprite.visible = true
		sprite.material = ShaderMaterial.new()
		sprite.material.shader = load("res://effects/outline.shader")
		sprite.material.set_shader_param("outline_color", Color("#f5eb97"))
		sprite.material.set_shader_param("width", 2)
	
func _process(delta):
	var move_distance = speed * delta
	move_along_path(move_distance)
	
func move_along_path(distance: float) -> void:
	var starting_point = position
	for i in range(path.size()):
		var distance_to_next = starting_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			position = starting_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif distance < 0.0:
			position = path[0]
			set_process(false)
			break
		distance -= distance_to_next
		starting_point = path[0]
		path.remove(0)
	
func has_collectable():
	return collectable != null
	
func is_enemy():
	return true
	
func set_target(target):
	self.target = target
	
func set_path(value: PoolVector2Array) -> void:
	path = value
	if value.size() == 0:
		return
	else:
		set_process(true)

func set_prompt(prompt: String):
	prompt_text = prompt
	self.prompt.bbcode_text = "[center]" + prompt_text + "[/center]"

func get_prompt() -> String:
	return prompt_text
	
func set_next_character(next_char_idx: int):
	curr_letter = prompt_text.substr(next_char_idx, 1)
	var green_text = get_bbcode_color_tag(green) + prompt_text.substr(0, next_char_idx) + get_bbcode_end_color_tag()
	var blue_text = get_bbcode_color_tag(blue) + prompt_text.substr(next_char_idx, 1) + get_bbcode_end_color_tag()
	var red_text = ""
	if next_char_idx != prompt_text.length():
		red_text = get_bbcode_color_tag(red) + prompt_text.substr(next_char_idx + 1, prompt_text.length() - next_char_idx + 1) + get_bbcode_end_color_tag()
	prompt.parse_bbcode("[center]" + green_text + blue_text + red_text + "[/center]")

func get_bbcode_color_tag(color: Color) -> String:
	return "[color=#" + color.to_html(false) + "]"
	
func get_bbcode_end_color_tag() -> String:
	return "[/color]"

func deselect():
	set_prompt(prompt_text)
	z_index = 0

func select():
	$Sprite.material.set_shader_param("width", 1.655)
	z_index = 50
	
func correctly_type():
	var instance = hit_particles.instance()
	add_child(instance)
	instance.start()
	emit_letter(curr_letter)
	
func emit_letter(letter):
	var instance = letter_particle.instance()
	add_child(instance)
	instance.set_letter(letter)
	instance.start()
	
func danger():
	$AnimationPlayer2.play("danger")

func _on_AnimationPlayer2_animation_finished(anim_name):
	if anim_name == "danger":
		# play danger_active
		$AnimationPlayer2.play("danger_active")
