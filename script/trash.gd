extends StaticBody2D

onready var game = get_node('/root/game')
onready var sprite = get_node('sprite')

var trash_list = data.trash.keys()
var trash_name

func init(trash_id, isle_id, pos):
	name = 'trash' + str(isle_id)
	global_position = pos
	
	trash_name = trash_list[trash_id]
	
	sprite.frame = trash_id

func _on_area_body_entered(body):
	if (body is KinematicBody2D):
		if (!('bullet' in body.name) and !body.is_slave and game.inventory.size() < body.max_inventory):
			if (!game.testmode):
				# game.rpc('update_score', get_tree().get_network_unique_id(), 1)
				game.rpc('remove_trash', name)
			else:
				game.remove_trash(name)
			
			game.inventory.append(trash_name)
			game.update_inventory_progress()
			
			queue_free()
