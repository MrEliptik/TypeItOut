extends KinematicBody2D

export (Color) var blue = Color("#4682b4")
export (Color) var green = Color("#639765")
export (Color) var red = Color("#a65455")

onready var prompt = $Word
onready var prompt_text = prompt.text.to_lower()

var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func is_enemy():
	return true
	
func set_target(target):
	self.target = target

func set_prompt(prompt: String):
	prompt_text = prompt
	self.prompt.bbcode_text = "[center]" + prompt_text + "[/center]"

func get_prompt() -> String:
	return prompt_text
	
func set_next_character(next_char_idx: int):
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

func selected():
	$Sprite.material.set_shader_param("width", 1.655)
	
func correctly_type():
	$Particles2D2.emitting = true
	
func danger():
	$Sprite/AnimatedSprite.scale = Vector2(0.0, 0.0)
	$Sprite/AnimatedSprite.visible = true
	$Tween.interpolate_property($Sprite/AnimatedSprite, "scale", Vector2(0.0, 0.0), Vector2(1.0, 1.0), 0.5, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	$Tween.start()
