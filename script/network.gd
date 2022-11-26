extends Node

signal player_number_changed
signal game_started
signal disconnected

var port = 8010
var port_alt = 8012

var game_started = false
var max_players = 0

var players = {}
var default = {'name': '', 'position': Vector2(0, 0), 'score': 0, 'items': [], 'color':  null}
var have_connected_before = false

var ip_address = ''
var colors = ['red', 'blue', 'green', 'yellow']
var positions = [Vector2(-4592, 112), Vector2(4592, 112)]

func _ready():
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			ip_address = ip
			
	get_tree().connect('network_peer_disconnected', self, 'on_player_disconnected')

func create_server(player_name, player_numbers):
	default.name = player_name
	max_players = player_numbers
	
	if (OS.get_name() != 'Server'):
		players[1] = default
	
	var peer = NetworkedMultiplayerENet.new()
	peer.compression_mode = NetworkedMultiplayerENet.COMPRESS_RANGE_CODER 
	peer.create_server(port, max_players)
	get_tree().set_network_peer(peer)

func connect_to_server(player_name, ip):
	# var ip = IP.get_local_addresses()[0]
	
	default.name = player_name
	var peer = NetworkedMultiplayerENet.new()
	peer.compression_mode = NetworkedMultiplayerENet.COMPRESS_RANGE_CODER 
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)

	get_tree().connect('connected_to_server', self, 'player_connected')
	get_tree().connect('connection_failed', self, 'connected_fail')
	get_tree().connect('server_disconnected', self, 'server_disconnected')
	
	ip_address = ip
	
func cancel_connection():
	get_tree().disconnect('connected_to_server', self, 'player_connected')
	get_tree().disconnect('connection_failed', self, 'connected_fail')
	get_tree().disconnect('server_disconnected', self, 'server_disconnected')
	
	get_tree().network_peer = null
	
	ip_address = ''

func player_connected():
	have_connected_before = true
	players[get_tree().get_network_unique_id()] = default
	rpc_id(1, 'send_player_info', get_tree().get_network_unique_id(), default)

func connected_fail():
	emit_signal('disconnected')

func server_disconnected():
	emit_signal('disconnected')

remote func get_latest_player_info(info):
	if (get_tree().is_network_server()):
		var count = 0
	
		for peer_id in info:
			info[peer_id].color = colors[count]
			info[peer_id].position = positions[count]
			count += 1
	
		for peer_id in info:
			if (peer_id != 1):
				rpc_id(peer_id, 'get_latest_player_info', info)
	else:
		players = info

remote func send_player_info(id, info):
	players[id] = info
	
	if (get_tree().is_network_server()):
		rpc('update_player_number', players.size(), max_players)
		if (players.size() == max_players):
			get_latest_player_info(players)
			rpc('load_game')
			
sync func update_player_number(number, max_players):
	emit_signal('player_number_changed', number, max_players)

sync func load_game():
	emit_signal('game_started')

	game_started = true 

	yield(get_tree().current_scene, "tree_exited")
	yield(get_tree(), "idle_frame")

	for peer_id in players:
		if (peer_id != get_tree().get_network_unique_id()):
			var info = players[peer_id]
			var new_player = load('res://player.tscn').instance()
			new_player.name = str(peer_id)
			new_player.set_network_master(peer_id)
			get_tree().get_root().add_child(new_player)
			new_player.init(info.name, info.position, info.color, true)

func reset_network():
	game_started = false
	max_players = 0

	players = {}
	have_connected_before = false
	get_tree().network_peer.close_connection()
	
	get_tree().disconnect('network_peer_disconnected', self, 'on_player_disconnected')

func on_player_disconnected(id):
	players.erase(id)
