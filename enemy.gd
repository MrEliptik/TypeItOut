extends KinematicBody2D

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

func selected():
	$Sprite.material.set_shader_param("width", 1.655)
	
func correctly_type():
	$Particles2D2.emitting = true
	
func danger():
	$Sprite/AnimatedSprite.scale = Vector2(0.0, 0.0)
	$Sprite/AnimatedSprite.visible = true
	$Tween.interpolate_property($Sprite/AnimatedSprite, "scale", Vector2(0.0, 0.0), Vector2(1.0, 1.0), 0.5, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	$Tween.start()
