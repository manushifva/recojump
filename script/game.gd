extends Node2D

var trash_instance = load('res://trash.tscn')
var panel_instance = load('res://panel.tscn')
var craftable_instance = load('res://craftable.tscn')
var leaderboard_instance = load('res://leaderboard.tscn')

export var testmode = false

# main game elements

onready var tips_label = get_node('loading/c/v/bg/m/v/tips')
onready var tiles = get_node('tiles')
onready var spawners = get_node('spawners')
onready var sfx_player = get_node('sfx')

# timers

onready var spawn_timer = get_node('spawn_timer')
onready var timer = get_node('ui/timer')
onready var loading_timer = get_node('loading/timer')
onready var level_timer = get_node('level_timer')

# main ui

onready var ui = get_node('ui')
onready var touchscreen = get_node('ui/touchscreen')
onready var disconnected_screen = get_node('ui/disconnected')
onready var loading = get_node('loading')
onready var transition = get_node('transition')
onready var transition_color = get_node('transition/color')
onready var animation = get_node('transition/animation')
onready var cooldown_label = get_node('ui/touchscreen/cooldown')
onready var attack_button = get_node('ui/touchscreen/attack')

# inventory ui

onready var inventory_ui = get_node('inventory_ui')
onready var inventory_slots = get_node('inventory_ui/m/h/v/inventory')
onready var item_slots = get_node('inventory_ui/m/h/v/item')
onready var craftable_slots = get_node('inventory_ui/m/h/v2/c/craftable')
onready var inventory_progress = get_node('ui/container/progress')
onready var inventory_progress_label = get_node('ui/container/label')
onready var inventory_container = get_node('ui/container')

# leaderboard ui

onready var leaderboard_ui = get_node('leaderboard_ui')
onready var leaderboard_slots = get_node('leaderboard_ui/m/v/')

# game end ui

onready var game_end_ui = get_node('game_end_ui')
# onready var score = get_node('leaderboard_ui/m/score')
onready var winner = get_node('game_end_ui/m/v/winner')

var camera_limit_left
var camera_limit_right

var cells = []
var isle = {}
var used = []

var game_time = 150

var inventory = []
var items = []

var trash_list = data.trash.keys()
var items_list = data.items.keys()

var click_to_sell = false

# main game

func _ready():
	loading.show()
	transition.show()
	animation.play_backwards('screen_transition')
	yield(animation, 'animation_finished')
	transition.hide()
	
	# rendering map
	var min_pos = Vector2(0, 0)
	var max_pos = Vector2(0, 0)
	
	var used_cells = tiles.get_used_cells()
	for cell in used_cells:
		if (cell.x > max_pos.x):
			max_pos = cell
		elif (cell.x < min_pos.x):
			min_pos = cell
			
	camera_limit_left = tiles.map_to_world(min_pos).x + tiles.cell_size.x
	camera_limit_right = tiles.map_to_world(max_pos).x
	
	# rendering player
	
	if (!testmode):
		network.connect('disconnected', self, 'disconnected')
		
		var new_player = load('res://player.tscn').instance()
		new_player.name = str(get_tree().get_network_unique_id())
		new_player.set_network_master(get_tree().get_network_unique_id())
		get_tree().get_root().add_child(new_player)
		var info = network.players[get_tree().get_network_unique_id()]

		new_player.init(info.name, info.position, info.color, false)
	else:
		network.max_players = 5
		network.players[0] = network.data
		
		var new_player = load('res://player.tscn').instance()
		add_child(new_player)
		
		new_player.init('test_player', Vector2(-1576, 248), 'red', false)
		
		render_inventory()
		update_inventory_progress()
		update_items(1, items)
		
		get_node('ui/timer_background').hide()
		timer.hide()
	
	spawners.hide()
	
	if (is_network_master() or testmode):
		cells = spawners.get_used_cells()
		
		var isle_count = 0
		var used_isle = 0
		
		for cell in cells:
			if (!(Vector2(cell.x - 1, cell.y) in cells)):
				isle_count += 1
				used_isle = 0
			
			if (used_isle == 0):
				used_isle = isle_count
				isle[used_isle] = [cell]
			else:
				isle[used_isle].append(cell)
	else:
		spawn_timer.stop()
	
	# rendering craftables
	
	for recipe in data.recipes:
		var craftable = craftable_instance.instance()
		craftable_slots.add_child(craftable)
	
		craftable.init(recipe, data.recipes[recipe].materials)
		
	loading_timer.start()
	
	randomize()
	tips_label.text = data.tips[randi() % data.tips.size()]
	
	yield(loading_timer, 'timeout')
	
	transition.show()
	animation.play('screen_transition')
	yield(animation, 'animation_finished')
	loading.hide()
	animation.play_backwards('screen_transition')
	yield(animation, 'animation_finished')
	transition.hide()
	
	ui.show()
	if (OS.get_name() == 'Android' or OS.get_name() == 'iOS'):
		touchscreen.show()
	
	if (!testmode):
		level_timer.start()

func _on_level_timer_timeout():
	game_time -= 1
	
	if (game_time > 0):
		var minutes = floor(game_time / 60)
		var seconds = game_time - (minutes * 60)

		if (len(str(minutes)) == 1):
			minutes = '0' + str(minutes)
			
		if (len(str(seconds)) == 1):
			seconds = '0' + str(seconds)
		
		timer.text = str(minutes) + ':' + str(seconds)
	else:
		if (get_tree().is_network_server() and network.game_started):
			rpc('end_game')
			network.game_started = false

sync func end_game():
	var max_score = {score = -1}
	for player in network.players:
		if (network.players[player].score > max_score.score):
			max_score = network.players[player]
	
	ui.hide()
	touchscreen.hide()
	inventory_ui.hide()
	leaderboard_ui.hide()
	
	winner.text = 'Pemenangnya adalah ' + max_score.name + ' dengan ' + str(max_score.score) + ' poin!'
	game_end_ui.show()
	
func back_to_lobby():
	for player in network.players:
		get_tree().get_root().get_node(str(player)).queue_free()
		
	get_tree().change_scene('res://lobby.tscn')
	
func _on_back_to_lobby_pressed():
	back_to_lobby()
	
func play_sfx(sfx):
	sfx_player.stream = load('res://')
	sfx_player.play()
	
# ui

func toggle_inventory():
	if (!inventory_ui.visible):
		ui.hide()
		inventory_ui.show()
		touchscreen.hide()
		inventory_container.hide()
		render_inventory()
	else:
		ui.show()
		inventory_ui.hide()
		inventory_container.show()
		
		if (OS.get_name() == 'Android' or OS.get_name() == 'iOS'):
			touchscreen.show()

func render_inventory():
	for child in inventory_slots.get_children():
		child.queue_free()

	for trash in trash_list:
		var count = inventory.count(trash)
		
		if (count > 0):
			var panel = panel_instance.instance()
			inventory_slots.add_child(panel)
			panel.init(trash_list.find(trash), count, 'trash')
			
	for item in items_list:
		if (item in inventory):
			var panel = panel_instance.instance()
			inventory_slots.add_child(panel)
			panel.init(items_list.find(item), 0, 'item')
			
	for child in item_slots.get_children():
		child.queue_free()

	for item in items:
		var panel = panel_instance.instance()
		item_slots.add_child(panel)
		panel.init(items_list.find(item), 0, 'item')
	
func update_inventory_progress():
	var player
	if (!testmode):
		player = get_tree().get_root().get_node(str(get_tree().get_network_unique_id()))
	else:
		player = get_node('player')
	
	inventory_progress.max_value = player.max_inventory
	inventory_progress.value = inventory.size()
	inventory_progress_label.text = str(inventory.size()) + '/' + str(player.max_inventory)
	
func _on_empty_pressed():
	click_to_sell = !click_to_sell
	
func _on_emptyall_pressed():
	var temp_score = 0
	for trash in trash_list:
		temp_score += inventory.count(trash) * data.trash[trash].value
		
	for item in items_list:
		if (item in inventory):
			temp_score += data.items[item].value

	inventory = []
				
	render_inventory()
	update_inventory_progress()

	if (!testmode):
		if ('Sentuhan Midas' in items):
			temp_score = temp_score * 2
		
		rpc('update_score', get_tree().get_network_unique_id(), temp_score)

func toggle_leaderboard():
	if (!leaderboard_ui.visible):
		ui.hide()
		leaderboard_ui.show()
		touchscreen.hide()
		render_leaderboard()
	else:
		ui.show()
		leaderboard_ui.hide()
		
		if (OS.get_name() == 'Android' or OS.get_name() == 'iOS'):
			touchscreen.show()

func render_leaderboard():
	for child in leaderboard_slots.get_children():
		if (child.name != 'label'):
			child.queue_free()
	
	for peer_id in network.players:
		var player = network.players[peer_id]
		
		var leaderboard = leaderboard_instance.instance()
		leaderboard_slots.add_child(leaderboard)
		leaderboard.init(player.name, player.color, player.items, player.score)

# trash spawning

func _on_spawn_timer_timeout():
	for x in range(network.max_players):
		var done = false
		if (isle.size() > used.size()):
			while !done:
				randomize()

				var isle_id = (randi() % isle.size()) + 1
				if (!isle_id in used):
					used.append(isle_id)
					
					var used_isle = isle[isle_id]
					var pos = used_isle[randi() % used_isle.size()]
					var trash_id = randi() % trash_list.size()
					
					if (!testmode):
						rpc('spawn_trash', pos, isle_id, trash_id)
					else:
						spawn_trash(pos, isle_id, trash_id)
					
					done = true

sync func spawn_trash(pos, isle_id, trash_id):
	var trash = trash_instance.instance()
	var cell_pos = spawners.map_to_world(pos)

	add_child(trash)
	
	trash.init(trash_id, isle_id, Vector2(cell_pos.x + 32, cell_pos.y + 32))
	
sync func remove_trash(trash_name):
	used.erase(int(trash_name.replace('trash', '')))
	get_node(trash_name).queue_free()

# scoring

sync func update_score(id, score):
	network.players[id].score += score

# items

sync func update_items(id, _items):
	if (!testmode):
		if (id == get_tree().get_network_unique_id()):
			items = _items
			
			var player = get_tree().get_root().get_node(str(id))
			
			for effect in data.default:
				player[effect] = data.default[effect]
			
			for i in items:
				var item = data.recipes[i]
				for effect in item.effects:
					player[effect] = item.effects[effect]
					
				if (item.type == 'combat'):
					player.attack_radius = item.radius
					player.attack_collision.shape.radius = item.radius
					player.update()
						
		network.players[id].items = _items
	else:
		items = _items
		var player = get_node('player')

		for i in items:
			var item = data.recipes[i]
			for effect in item.effects:
				player[effect] = item.effects[effect]
				
			if (item.type == 'combat'):
				player.attack_radius = item.radius
				player.attack_collision.shape.radius = item.radius

# network error

func disconnected():
	disconnected_screen.show()

func _on_reconnect_pressed():
	back_to_lobby()
