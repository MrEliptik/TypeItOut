extends Area2D

export var speed = 3000.0
export var steer_force = 1800.0

const ANGLE = 10.0

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(_shooter, letter, _target):
	$Letter.text = str(letter)
	global_position = _shooter.global_position
	look_at(_target.global_position)
	rotation_degrees += rand_range(-ANGLE, ANGLE)
	velocity = transform.x * speed
	target = _target
	
func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.global_position - global_position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	position += velocity * delta
	# Keep the letter visible
	$Letter.rect_rotation = -rotation
	#var mat = $Particles2D.get_process_material()
	#mat.angle = rotation_degrees
	
func explode():
	# TODO: add animation or particles
	queue_free()

func _on_Timeout_timeout():
	explode()

func _on_Bullet_area_entered(area):
	explode()
