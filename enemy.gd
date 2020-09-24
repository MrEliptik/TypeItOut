extends Area2D

export (Color) var blue = Color("#45abff")
export (Color) var green = Color("#63c766")
export (Color) var red = Color("#e83f40")

const hit_particles = preload("res://hitEnemyParticles.tscn")
const letter_particle = preload("res://lostLetter.tscn")

const COLOR_PADDING = 15

onready var prompt = $LabelContainer/Word
onready var prompt_text = prompt.text.to_lower()

var sprites = ["res://sprites/enemy/enemy_ufoGreen_E.png", "res://sprites/enemy/enemy_ufoPurple_E.png",
	"res://sprites/enemy/enemy_ufoRed_E.png", "res://sprites/enemy/enemy_ufoYellow_E.png"]

var speed = 35.0
var speed_random_range = 10.0
var collectable_chance = 0.10

var curr_letter = null

var target = null
var path : = PoolVector2Array() setget set_path

var collectable = null

var _next_char_idx = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_process(false)
	
	$Sprite.texture = load(sprites[int(rand_range(0, sprites.size()))])
	# Draw random item at 10% chance
	if(randf() < collectable_chance):
		var idx = int(rand_range(0, Inventory.type_Sprite.size()))
		collectable = idx
		
		var sprite = $LabelContainer/Label/Circle/Collectable
		sprite.texture = load(Inventory.type_Sprite[idx])
		$LabelContainer/Label/Circle.visible = true
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
			#set_process(false)
			break
		distance -= distance_to_next
		starting_point = path[0]
		path.remove(0)
	
func has_collectable():
	return collectable != null
	
func is_enemy():
	return true
	
func set_speed(value):
	# Add some randomness
	var speed_random = rand_range(-speed_random_range, speed_random_range)
	speed = value + speed_random
	print("Value: "+str(value)+" Rand: "+str(speed_random)+" Speed: "+str(speed))
	
func set_target(target):
	self.target = target
	
func set_path(value: PoolVector2Array) -> void:
#	var trail  = Line2D.new()
#	get_parent().get_parent().add_child(trail)
#	trail.points = value
	
	path = value
	if value.size() == 0:
		return
	else:
		set_process(true)

func set_prompt(value: String):
	prompt_text = value.to_lower()
	prompt.bbcode_text = "[center]" + prompt_text + "[/center]"
	adjust_word_size() 

func get_prompt() -> String:
	return prompt_text
	
func adjust_word_size():
	# Calculate the desired size
	var font = prompt.get_font("normal_font")
	var pixel_length = font.get_string_size(prompt_text)
	
	# To avoid scaling the font, we need to set the rect size,
	# but also to move it to make it centererd
	var difference = (prompt.rect_size.x - pixel_length.x) - COLOR_PADDING
	prompt.rect_size.x -= difference
	prompt.rect_position.x += difference/2
	
	var ratio = prompt.rect_size.x/pixel_length.x
	
	difference = ($LabelContainer/Label.rect_size.x - pixel_length.x) - 80
	$LabelContainer/Label.rect_size.x -= difference
	$LabelContainer/Label.rect_position.x += difference/2
	$LabelContainer/Label.rect_pivot_offset.x = $LabelContainer/Label.rect_size.x/2
	
func set_next_character(next_char_idx: int):
	_next_char_idx = next_char_idx
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
	
func die():
	$AnimationPlayer.play("die")
	
func correctly_type():
	#var instance = hit_particles.instance()
	#$ParticlesContainer.add_child(instance)
	#instance.start()
	#emit_letter(curr_letter)
	pass
	
func emit_letter(letter):
	var instance = letter_particle.instance()
	$ParticlesContainer.add_child(instance)
	instance.set_letter(letter)
	instance.start()
	
func danger():
	$AnimationPlayer2.play("danger")

func _on_AnimationPlayer2_animation_finished(anim_name):
	if anim_name == "danger":
		# play danger_active
		$AnimationPlayer2.play("danger_active")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		queue_free()
