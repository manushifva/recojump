extends KinematicBody2D

var speed = 1000
var steer_force = 150
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

var direction = 1

var sender
var target
var hit_count = 0

func init(pos, send, targ):
	randomize()
	
	global_position = pos
	sender = send
	target = targ
	direction = randi() % 280

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

func _on_area_body_entered(body):
	if (!(body is KinematicBody2D)):
		hit_count += 1
		if (hit_count >= 4):
			queue_free()
