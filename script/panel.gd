extends TextureButton

onready var game = get_node('/root/game')
onready var sprite = get_node('sprite')
onready var label = get_node('label')

var clickable

func _ready():
	pass
	
func init(index, number, _clickable = true):
	sprite.frame = index
	label.text = str(number)
	clickable = _clickable

func _on_panel_pressed():
	if (game.click_to_sell and clickable):
		var item = data.trash.keys()[sprite.frame]
		var value = data.trash[item].value
		
		if ('Sentuhan Midas' in game.items):
			value = value * 2
		
		game.rpc('update_score', get_tree().get_network_unique_id(), value)
		
		game.inventory.erase(item)
		game.render_inventory()
		game.update_inventory_progress()

func change_color():
	pass
