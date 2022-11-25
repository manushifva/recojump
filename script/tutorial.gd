extends CanvasLayer

onready var game = get_node('/root/game')
onready var player = get_node('/root/game/player')
onready var tips = get_node('v/bg/m/v/tips')

var index = 0
var is_in_action = false
var steps = [
	'Untuk bergerak, gunakan tombol kiri-kanan yang ada di pojok kiri bawah layar.',
	'Untuk melompat, gunakan tombol panah atas yang ada di pojok kanan bawah layar.',
	'Kamu sepertinya sudah tahu cara bergerak. Sekarang, kumpulkan sampah-sampah yang ada disana. Kumpulakn sampai bar yang ada di pojok kiri atas penuh ya!',
	'Kerja bagus! Sekarang, klik tombol tas yang ada di pojok kanan atas.',
	'Geser bagian "Crafting menu" sampai kamu menemukan pilihan "Tongkat meteor", lalu klik "Buat item"',
	'Sekarang, kamu sudah memiliki "Tongkat meteor". Keren! Coba serang boneka disana dengan tombol serangan yang berada di sebelah tombol lompat.',
	'Selamat, kamu sudah mempelajari dasar-dasar di permainan ini! Sekarang, ajak temanmu untuk bermain!'
]

func init():
	show()
	
func show_text():
	game.touchscreen.hide()
	show()
	tips.text = steps[index]
	index += 1
	
func _input(event):
	if (event is InputEventMouseButton and event.pressed):
		if (index == 0):
			show_text()
			is_in_action = true
		else:
			if (is_in_action):
				if (OS.get_name() == 'Android' or OS.get_name() == 'iOS' and !game.inventory_ui.visible):
					game.touchscreen.show()
				hide()
				
	if ((Input.is_action_just_pressed('ui_left') or Input.is_action_pressed('ui_right')) and index == 1):
		show_text()
		
	if (Input.is_action_just_pressed('ui_up') and index == 2):
		show_text()
		
	if (game.inventory.size() >= 25 and index == 3):
		show_text()
		
	if (Input.is_action_just_pressed('inventory') and index == 4):
		show_text()
		
	if ('Tongkat meteor' in game.items and index == 5):
		show_text()
		
	if (Input.is_action_just_pressed('attack') and index == 6):
		show_text()

func _on_Button_pressed():
	get_tree().change_scene('res://lobby.tscn')
