extends AnimatedSprite

onready var tween = get_node('tween')

func init(pos, fr, flip, mod):
	global_position = pos
	frame = fr
	flip_h = flip
	
	tween.interpolate_property(self, 'modulate', Color(mod.r, mod.g, mod.b, 0.9), Color(mod.r, mod.g, mod.b, 0), 0.7)
	tween.start()
	yield(tween, 'tween_completed')
	queue_free()
