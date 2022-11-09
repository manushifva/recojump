extends TextureButton

onready var game = get_node('/root/game')
onready var trash = get_node('trash')
onready var item = get_node('item')
onready var label = get_node('label')

var clickable
var item_name
var type

func _ready():
	pass
	
func init(index, number, _type, _clickable = true):
	type = _type
	if (type == 'trash'):
		trash.show()
		trash.frame = index
	if (type == 'item'):
		label.hide()
		item.show()
		item.frame = index
		item_name = data.items.keys()[index]
	
	label.text = str(number)
	clickable = _clickable

func _on_panel_pressed():
	if (type == 'trash'):
		if (game.click_to_sell and clickable):
			var item = data.trash.keys()[trash.frame]
			var value = data.trash[item].value
		
			if ('Sentuhan Midas' in game.items):
				value = value * 2
		
			game.rpc('update_score', get_tree().get_network_unique_id(), value)
		
			game.inventory.erase(item)
			game.render_inventory()
			game.update_inventory_progress()
	if (type == 'item'):
		if (game.click_to_sell):
			var value = data.items[item_name].value
		
			if ('Sentuhan Midas' in game.items):
				value = value * 2
		
			game.rpc('update_score', get_tree().get_network_unique_id(), value)
		
			game.inventory.erase(item_name)
			game.render_inventory()
			game.update_inventory_progress()
		else:
			if (item_name in game.items):
				var player
				if (!game.testmode):
					player = get_tree().get_root().get_node(str(get_tree().get_network_unique_id())).max_inventory
				else:
					player = game.get_node('player')
				
				if (game.inventory.size() < player):
					game.items.erase(item_name)
					game.inventory.append(item_name)
			else:
				if (game.items.size() < 2):
					game.inventory.erase(item_name)
					game.items.append(item_name)
				
			game.rpc('update_items', get_tree().get_network_unique_id(), game.items)
			game.render_inventory()
			game.update_inventory_progress()

func change_color():
	pass
