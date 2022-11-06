extends CanvasLayer

export var autoenter = false

var player_instance = load('res://player.tscn')
var server_button_instance = load('res://server_button.tscn')

onready var button_container = get_node('m/v/button_container')
onready var search_server_button = get_node('m/v/button_container/search_server')
onready var create_server_button = get_node('m/v/button_container/create_server')
onready var room_setting = get_node('m/v/room_setting')
onready var player_name = get_node('m/v/name_container/name')
onready var status = get_node('m/v/status')
onready var server_list = get_node('m/v/server_list')
onready var cancel_button = get_node('cancel_container/cancel')
onready var player_numbers = get_node('m/v/room_setting/h/player_number')
onready var animation = get_node('animation')
onready var transition = get_node('transition')

var broadcaster_instance = load('res://broadcaster.tscn')
var listener_instance = load('res://listener.tscn')

var broadcast_or_listener_node = null

func _ready():
	if (autoenter):
		if (OS.get_name() == 'Server'):
			player_name.text = 'Server'
			_on_create_pressed()
		else:
			connect_to_server('127.0.0.1')
	
func disable_buttons():
	search_server_button.disabled = true
	create_server_button.disabled = true

func connect_to_server(ip):
	if (player_name.text != ''):
		button_container.hide()
		player_name.editable = false
		cancel_button.show()
		
		network.connect_to_server(player_name.text, ip)
		network.connect('disconnected', self, 'disconnected')
		network.connect('player_number_changed', self, 'player_number_changed')
		network.connect('game_started', self, 'load_game')

func _on_create_server_pressed():
	button_container.hide()
	room_setting.show()
	cancel_button.show()

func _on_create_pressed():
	if (player_name.text != ''):
		button_container.hide()
		room_setting.hide()
		player_name.editable = false
		cancel_button.show()
		
		network.create_server(player_name.text, player_numbers.value)
		network.connect('player_number_changed', self, 'player_number_changed')
		network.connect('game_started', self, 'load_game')
		
		status.text = 'Menunggu pemain lain (1/' + str(player_numbers.value) + ') ...'
		
		broadcast_or_listener_node = broadcaster_instance.instance()
		add_child(broadcast_or_listener_node)

func _on_search_server_pressed():
	button_container.hide()
	server_list.show()
	cancel_button.show()
	
	broadcast_or_listener_node = listener_instance.instance()
	add_child(broadcast_or_listener_node)
	broadcast_or_listener_node.connect('new_server', self, 'add_server_list')
	broadcast_or_listener_node.connect('remove_server', self, 'remove_server_list')
	
func add_server_list(info):
	var server_button = server_button_instance.instance()
	server_button.name = 'server' + info.ip
	server_list.add_child(server_button)
	
	server_button.init(info)
	server_button.connect('connect_to_server', self, 'connect_to_server')

func _on_cancel_pressed():
	button_container.show()
	
	server_list.hide()
	room_setting.hide()
	
	for child in server_list.get_children():
		if (child.name != 'label'):
			child.queue_free()

	player_name.editable = true
	cancel_button.hide()
	
	status.text = ''
	
	if (broadcast_or_listener_node != null):
		broadcast_or_listener_node.queue_free()
		broadcast_or_listener_node = null
	
	network.cancel_connection()
	network.disconnect('disconnected', self, 'disconnected')
	network.disconnect('game_started', self, 'load_game')
	
func load_game():
	transition.show()
	animation.play('screen_transition')
	yield(animation, 'animation_finished')
	
	get_tree().change_scene('res://game.tscn')
	
func remove_server_list(ip):
	server_list.get_node('server' + ip.replace('.', '')).queue_free()
	
func player_number_changed(number, max_players):
	status.text = 'Menunggu pemain lain (' + str(number) + '/' + str(max_players) + ') ...'
	
func disconnected():
	status.text = 'Gagal menyambung'
