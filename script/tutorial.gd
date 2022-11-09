extends CanvasLayer

onready var game = get_node('/root/game')
onready var player = get_node('/root/game/player')
onready var tips = get_node('v/bg/m/v/tips')

var index = 0
var is_in_action = false
var steps = [
	'Untuk bergerak, gunakan tombol kiri-kanan yang ada di pojok kiri bawah layar.',
	'Untuk melompat, gunakan tombol panah atas yang ada di pojok kanan bawah layar.',
	'Kamu sepertinya sudah tahu cara bergerak. Sekarang, kumpulkan sampah-sampah yang ada disana.',
	'Kerja bagus! Sekarang, klik tombol tas yang ada di pojok kanan atas.',
	'Geser bagian "Crafting menu" sampai kamu menemukan pilihan "Tongkat meteor", lalu klik "Buat item"',
	'Sekarang, kamu sudah memiliki "Tongkat meteor". Keren! Coba serang boneka disana dengan tombol serangan yang berada di sebelah tombol lompat.',
	'Selamat, kamu sudah mempelajari dasar-dasar di permainan ini! Sekarang, ajak temanmu untuk bermain!'
]

func _ready():
	show()
	
func render_tips():
	show()
	tips.text = steps[index]
	index += 1
	is_in_action = true
	
func _input(event):
	if (index != 0):
		if (event is InputEventMouseButton or event is InputEventScreenTouch and event.pressed and !is_in_action):
			hide()
	else:
		render_tips()
		
	if (Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right') and index == 1):
		render_tips()
		is_in_action = false
	if (Input.is_action_just_pressed('ui_up') and index == 2):
		render_tips()
		is_in_action = false
	elif (index == 3 and game.inventory.size() == 5):
		render_tips()
		is_in_action = false
