extends MarginContainer

var panel_instance = load('res://panel.tscn')

onready var name_label = get_node('h/v/name')
onready var score_label = get_node('h/score')
onready var items = get_node('h/v/items')
onready var profile = get_node('h/profile')

var colors = {'red': Color(1, 0.37, 0.38), 'blue': Color(0.37, 0.69, 1), 'green': Color(0.47, 1, 0.3), 'yellow': Color(1, 0.95, 0.19)}

func _ready():
	pass # Replace with function body.

func init(player_name, player_color, player_items, player_score):
	name_label.text = player_name
	score_label.text = str(player_score)
	profile.modulate = colors[player_color]
	
	for item in player_items:
		var panel = panel_instance.instance()
		items.add_child(panel)
		panel.init(data.items.keys().find(item), 0, 'item')
