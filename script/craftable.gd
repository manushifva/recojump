extends VBoxContainer

var panel_instance = load('res://panel.tscn')

onready var game = get_node('/root/game')
onready var name_label = get_node('name')
onready var material_slots = get_node('material')
onready var item = get_node('material/item')

var item_name = ''
var item_materials = []

func init(_name, materials):
	item_name = _name
	name_label.text = _name
	
	item.init(data.items.keys().find(_name), 0, 'item')
	
	item_materials = materials
	for _material in item_materials:
		var panel = panel_instance.instance()
		material_slots.add_child(panel)
		
		panel.init(data.trash.keys().find(_material), item_materials[_material], 'trash', false)

func _on_button_pressed():
	if (!item_name in game.items and !item_name in game.inventory):
		var have_all_materials = true
		for _material in item_materials:
			if (!game.inventory.count(_material) >= item_materials[_material]):
				have_all_materials = false
		
		if (have_all_materials):
			for _material in item_materials:
				for x in item_materials[_material]:
					game.inventory.erase(_material)
			
			if (game.items.size() < 2):
				game.items.append(item_name)
				if (!game.testmode):
					game.rpc('update_items', get_tree().get_network_unique_id(), game.items)
				else:
					game.update_items(1, game.items)
			else:
				game.inventory.append(item_name)

			game.render_inventory()
			game.update_inventory_progress()
