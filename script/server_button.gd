extends MarginContainer

signal connect_to_server

onready var server_name = get_node('h/server_name')

export var server_ip = ''

func init(info):
	server_ip = info.ip
	server_name.text = info.name + '(' + server_ip +  ')'

func _on_server_button_pressed():
	emit_signal('connect_to_server', server_ip)
