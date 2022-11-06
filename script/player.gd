extends KinematicBody2D

var bullet_instance = load('res://bullet.tscn')

onready var game = get_node('/root/game')
onready var name_label = get_node('name')
onready var sprite = get_node('sprite')
onready var camera = get_node('camera')
onready var stun_timer = get_node('stun')
onready var progress = get_node('progress')
onready var tween = get_node('tween')
onready var muzzle = get_node('muzzle')
onready var attack_collision = get_node('area/collision')
onready var sfx_player = get_node('sfx')

var colors = {'red': Color(1, 0.37, 0.38), 'blue': Color(0.37, 0.69, 1), 'green': Color(0.47, 1, 0.3), 'yellow': Color(1, 0.95, 0.19)}

var is_slave = false
var speed = 500
var gravity = 5000
var jump = 1250
var target = null
var color = null
var attack_radius = 1
var max_inventory = 25

puppet var slave_pos = Vector2.ZERO
puppet var slave_motion = Vector2.ZERO

puppet var slave_action = 'idle'
puppet var slave_is_right = false
puppet var slave_weapon = null
puppet var slave_stunned = false
puppet var slave_attack_radius = 1

var motion = Vector2.ZERO
var knockdir = Vector2.ZERO
var knock_power = 0
var max_knock = 0
var action = 'idle'
var is_right = false
var weapon = null
var stunned = false
var anti_stun_owned = false

var jump_max = 2
var jump_count = 0

func _ready():
	pass
	
func play_sfx(sfx):
	pass
	
func init(player_name, player_pos, player_color, is_been_slave):
	name_label.text = player_name
	global_position = player_pos
	is_slave = is_been_slave
	
	color = colors[player_color]
	sprite.modulate = color
	
	if (!is_slave):
		camera.current = true
		camera.limit_left = game.camera_limit_left
		camera.limit_right = game.camera_limit_right
	
remote func update_state(pos, mot, is_right, act, wea, _stun, rad):
	slave_pos = pos
	slave_motion = mot
	slave_is_right = is_right
	slave_action = act
	slave_weapon = wea
	slave_stunned = _stun
	slave_attack_radius = rad
	
func _physics_process(delta):
	if (!is_slave):
		var x_input = 0
		if (!stunned):
			x_input = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
		
		if (x_input != 0):
			sprite.flip_h = x_input < 0
		
		motion.x = x_input * speed
		motion.y += gravity * delta
		
		if (is_on_floor() and jump_count != 0):
			jump_count = 0
		
		if (!stunned):
			if (Input.is_action_just_pressed('ui_up') and jump_count < jump_max):
				motion.y = -jump
				jump_count += 1

			if (Input.is_action_pressed('ui_right') or Input.is_action_pressed('ui_left')):
				action = 'walk'
				play_sfx('walk')
			else:
				action = 'idle'
				
		if (Input.is_action_just_pressed('attack')):
			if (target):
				if (weapon == 'Tangan pencuri'):
					target.rpc('stun', 1)
					target.rpc('take_item', get_tree().get_network_unique_id())
				elif (weapon == 'Tatapan Medusa'):
					target.rpc('stun', 3, 'petrify')
				elif (weapon == 'Tongkat meteor'):
					var locked = target
					for x in range(3):
						yield(get_tree().create_timer(0.3), 'timeout')
						
						if (!game.testmode):
							rpc('spawn_bullet', int(locked.name))
						else:
							spawn_bullet(self)
		
		if (Input.is_action_just_pressed('inventory')):
			game.toggle_inventory()
		elif (Input.is_action_just_pressed('leaderboard')):
			game.toggle_leaderboard()
		
		if (!game.testmode):
			rpc('update_state', position, motion, sprite.flip_h, action, weapon, stunned, attack_radius)
	else:
		position = slave_pos
		motion = slave_motion
		action = slave_action
		sprite.flip_h = slave_is_right
		weapon = slave_weapon
		stunned = slave_stunned
		attack_radius = slave_attack_radius
	
	sprite.play(action)
	
	if (knockdir != Vector2.ZERO):
		if (max_knock == 0):
			max_knock = knock_power + 1
		
		knockdir.y -= knock_power * 2
			
		knockdir.x = knockdir.x * speed
		
		knockdir = move_and_slide(knockdir.normalized() * speed, Vector2.ZERO)
		motion = knockdir
		knock_power -= 1
		
		if (knock_power < 0):
			knock_power = 0
			knockdir = Vector2.ZERO
	else:
		motion = move_and_slide(motion, Vector2.UP)
	
	if (position.y > 2000):
		position = Vector2(0, 0)
	if (is_slave):
		slave_pos = position
		
	update()
		
sync func stun(duration, effect = null):
	progress.show()
	stunned = true
	
	if (anti_stun_owned):
		duration = duration * 0.5
	
	var start_modulate = sprite.modulate
	if (effect == 'petrify'):
		sprite.modulate = Color(0.38, 0.38, 0.38)
	
	progress.value = 100
	tween.interpolate_property(progress, 'value', 100, 0, duration)
	tween.start()
	
	stun_timer.wait_time = duration
	stun_timer.start()
	
	yield(stun_timer, 'timeout')
	
	sprite.modulate = color
	
	stunned = false
	progress.hide()
	
sync func take_item(sender):
	if (is_network_master() and !('Tas superbesar' in game.items)):
		randomize()
		if (game.inventory.size() > 0):
			var taken_item = game.inventory[randi() % game.inventory.size()]
			game.inventory.erase(taken_item)
		
			get_tree().get_root().get_node(str(sender)).rpc('give_item', taken_item)
			game.update_inventory_progress()

sync func give_item(item):
	if (is_network_master()):
		if (game.inventory.size() < max_inventory):
			game.inventory.append(item)
			game.update_inventory_progress()
		
sync func spawn_bullet(target):
	var bullet = bullet_instance.instance()
	game.add_child(bullet)
	
	var bullet_target
	if (!game.testmode):
		bullet_target = get_tree().get_root().get_node(str(target))
	else:
		bullet_target = self
	
	bullet.init(muzzle.global_position, self, bullet_target)
		
func _draw():
	if (weapon and !stunned):
		var radius = attack_radius
		var maxerror = 0.25
			
		var maxpoints = 1024 # I think this is renderer limit

		var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
		numpoints = clamp(numpoints, 3, maxpoints)

		var points = PoolVector2Array([])

		for i in numpoints:
			var phi = i * PI * 2.0 / numpoints
			var v = Vector2(sin(phi), cos(phi))
			points.push_back(v * radius)

		if (!is_slave):
			draw_colored_polygon(points, Color(1.0, 1.0, 1.0, 0.2))
		else:
			var modulate_color = color
			modulate_color.a = 0.3
			
			draw_colored_polygon(points, modulate_color)

func _on_area_body_entered(body):
	if (body.name != str(get_tree().get_network_unique_id()) and !('bullet' in body.name) and body is KinematicBody2D and target == null):
		target = body

func _on_area_body_exited(body):
	if (body == target):
		target = null

func _on_hitbox_body_entered(body):
	if ('bullet' in body.name):
		if (body.sender != self):
			if (!anti_stun_owned):
				knock_power = 20
				knockdir = transform.origin - body.transform.origin
			
			rpc('stun', 1)
			body.queue_free()
