extends Area2D

export var speed = 1500.0
export var steer_force = 400.0

enum TYPE{
	SINGLE_TURRET,
	DOUBLE_TURRET
}

var sprite_type = {
	TYPE.SINGLE_TURRET: "res://sprites/defenses/turret_single_SW.png",
	TYPE.DOUBLE_TURRET: "res://sprites/defenses/turret_double_SW.png",
}

const ANGLE = 20.0

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(_shooter, type, _target):
	$Sprite.texture = load(sprite_type[type])
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
	
func explode():
	# TODO: add animation or particles
	queue_free()

func _on_Timeout_timeout():
	explode()

func _on_CollectableBullet_body_entered(body):
	if body.get_name() == "Player":
		explode()
