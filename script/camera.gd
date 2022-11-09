extends Camera2D

onready var tween = get_node('tween')
onready var timer = get_node('timer')

var shake_amount = 0
var default_offset = offset

func _ready():
	set_process(false)
	randomize()
	
func _process(delta):
	offset = Vector2(rand_range(-1, 1) * shake_amount, rand_range(-1, 1) * shake_amount)
	
func shake(time, amount):
	timer.wait_time = time
	shake_amount = amount
	set_process(true)
	timer.start()

func _on_timer_timeout():
	set_process(false)
	tween.interpolate_property(self, 'offset', offset, default_offset, 0.1, 6, 2)
	tween.start()
