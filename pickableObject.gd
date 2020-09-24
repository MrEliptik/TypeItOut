extends Node2D

signal attack(who, what)
signal place(who)
signal cancel(who)

enum TYPE{
	SINGLE_TURRET,
	DOUBLE_TURRET
}

var type_AnimatedSprite = {
	TYPE.SINGLE_TURRET : "res://sprites/defenses/turret_single.tres",
	TYPE.DOUBLE_TURRET : "res://sprites/defenses/turret_double.tres",
}

var type
# Until placed, follow the mouse position
var placed = false

var target = null
var letter = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	if placed: return
	if Input.is_action_pressed("right_click"):
		# User cancel placement
		# TODO: notify inventory of cancelling
		cancel()
	elif Input.is_action_pressed("left_click"):
		place(get_global_mouse_position())
	global_position = get_global_mouse_position()
	can_place(global_position)
	update()

func _draw():
	#draw_circle_custom($Groupe/AttackArea/CollisionShape2D.shape.radius, Color("#1c84defe"))
	draw_circle_arc(Vector2(0.0, 0.0), $Groupe/AttackArea/CollisionShape2D.shape.radius, 0, 360, Color("#d684defe"))
	draw_circle(Vector2(0.0, 0.0), $Groupe/AttackArea/CollisionShape2D.shape.radius, Color("#1c84defe"))
	draw_set_transform(transform.origin, 0.0, Vector2(2.0, 0.5))

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 1024
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)

func draw_circle_custom(radius, color, maxerror = 0.25):
	if radius <= 0.0:
		return

	var maxpoints = 1024 # I think this is renderer limit
	var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
	numpoints = clamp(numpoints, 3, maxpoints)

	var points = PoolVector2Array([])
	for i in numpoints:
		var phi = i * PI * 2.0 / numpoints
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius)

	draw_colored_polygon(points, color)

func init(type):
	self.type = type
	$Groupe/AnimatedSprite.frames = load(type_AnimatedSprite[type])
	$Groupe/VBoxContainer.visible = false
	$AnimationPlayer.play("moving")
	
func place(where):
	#TODO: add sfx or screen shake to show can't place
	if !can_place(where): 
		$NoSound.play()
		return
	$Groupe/VBoxContainer.visible = true
	placed = true
	global_position = where
	reset_pos()
	
func can_place(where):
	if !true:
		$Groupe/AnimatedSprite.modulate = Color("#df6262")
		return false
	else:
		$Groupe/AnimatedSprite.modulate = Color("#5fe14d")
		return true
	
func reset_pos():
	$Groupe/AnimatedSprite.scale = Vector2(1.0, 1.0)
	$Groupe/AnimatedSprite.rotation_degrees = 0
	$AnimationPlayer.stop()

func cancel():
	placed = false
	emit_signal("cancel", self)
	queue_free()

func _on_Yes_pressed():
	$YesSound.play()
	$Groupe/VBoxContainer.visible = false
	$Groupe/AnimatedSprite.modulate = Color("#ffffff")
	# TODO: animate visibility (boucny effect?)
	$AnimationPlayer.play("place")
	emit_signal("place", self, type)

func _on_No_pressed():
	$NoSound.play()
	$Groupe/VBoxContainer.visible = false
	placed = false

func _on_AttackTimer_timeout():
	#print(global_position.angle_to(target.global_position))
	emit_signal("attack", self, target)
	$AttackSound.play()

func _on_Area2D_mouse_entered():
	print("mouse entered")

func _on_Area2D_mouse_exited():
	print("mouse exited")

func _on_AttackArea_area_entered(area):
	if !target && area.has_method("is_enemy"):
		target = area
		$AttackTimer.start()

func _on_AttackArea_area_exited(area):
	if area.has_method("is_enemy"):
		target = null
		$AttackTimer.stop()
