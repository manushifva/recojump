extends StaticBody2D

onready var game = get_node('/root/game')
onready var sprite = get_node('sprite')
onready var tween = get_node('tween')

var trash_list = data.trash.keys()
var trash_name

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

var target
var already_taken = false
var already_fly = false
var fly_position

func _ready():
	scale = Vector2(0, 0)

func init(trash_id, isle_id, pos):
	tween.interpolate_property(self, 'scale', Vector2(0, 0), Vector2(1, 1), 0.3)
	tween.start()
	
	name = 'trash' + str(isle_id)
	global_position = pos
	
	trash_name = trash_list[trash_id]
	
	sprite.frame = trash_id
	
	fly_position = Vector2(position.x, position.y - 92)
	
	set_process(false)

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * 2000
		steer = (desired - velocity).normalized() * 500
	return steer

func _process(delta):
	if (already_fly):
		# global_position.x += direction * delta
		
#		acceleration += seek()
#		velocity += acceleration * delta
#		velocity = velocity.clamped(2000)
#		global_rotation = velocity.angle()
#		global_position += velocity * delta

		global_position = lerp(global_position, target.global_position, 0.2)

		if (target.global_position.distance_to(global_position) <= 70 or target.global_position.distance_to(global_position) >= 450):
			queue_free()
	else:
		global_position.y -= 5
		
	if (fly_position.y >= global_position.y):
		already_fly = true

func _on_area_body_entered(body):
	if (body is KinematicBody2D and !already_taken):
		if (!('bullet' in body.name) and !body.is_slave and game.inventory.size() < body.max_inventory):
			already_taken = true
			
			tween.interpolate_property(self, 'scale', Vector2(1, 1), Vector2(0.3, 0.3), 0.3)
			tween.start()
			sprite.hide()
			
			game.inventory.append(trash_name)
			game.update_inventory_progress()
			
			if (!game.testmode):
				# game.rpc('update_score', get_tree().get_network_unique_id(), 1)
				game.rpc('remove_trash', name)
			else:
				game.remove_trash(name)
			
			set_as_toplevel(true)
			
			yield(tween, 'tween_completed')
		
			target = body
			set_process(true)
