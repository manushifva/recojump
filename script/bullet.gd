extends KinematicBody2D

onready var tween = get_node('tween')

var speed = 1000
var steer_force = 150
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

var direction = 1

var sender
var target

var already_fly = false

func _ready():
	scale = Vector2(0, 0)

func init(pos, send, targ):
	global_position = pos
	sender = send
	target = targ
	
	tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(1, 1), 0.3)
	tween.start()
	
	yield(tween, 'tween_completed')

	already_fly = true

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _process(delta):
	# global_position.x += direction * delta
	
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	global_rotation = velocity.angle()
	global_position += velocity * delta

#	if (already_fly):
#		if (global_position.distance_to(target) >= 10):
#			global_position = lerp(global_position, target, 0.1)
#		else:
#			global_position += transform.x * speed * delta 

func _on_area_body_entered(body):
	if (!(body is KinematicBody2D)):
		queue_free()
