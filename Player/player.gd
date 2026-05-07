extends CharacterBody2D

var movement_speed = 40.0
var hp = 80

# Attack
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")

# Attack Nodes
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")

#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1

# Enemy Related
var enemy_close = []

@onready var sprite = $Sprite2D
# walkTimer is set as unique path for referencing, rather than calling upon the node within the player
@onready var walkTimer = get_node("%walkTimer")

func _ready():
	attack()

# primary game loop, updates on every single physics frame. 
# Delta is 1 second divided by framerate. Stops movement speed being tied with framerate
func _physics_process(delta): 
	movement()

func movement():
	# if moving right, x = 1. if moving left, x = -1. if moving left and right, x = 0
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	# same goes for y. up is negative and down is positive
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# determines direction of movement
	var mov = Vector2(x_mov, y_mov)
	
	# face left or right animation
	if mov.x > 0:
		sprite.flip_h = true
	if mov.x < 0:
		sprite.flip_h = false
	
	if mov != Vector2.ZERO:
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1: # hframe start at 1 and frame start at 0
				sprite.frame = 0
			else:
				sprite.frame = 1
			walkTimer.start()
	
	# add speed to make movement. Normalization is to stop making diagonal movement faster than a grid movement
	velocity = mov.normalized()*movement_speed
	move_and_slide() # what makes the character move

func attack():
	if icespear_level > 0: # Do we have a valid icespear attack?
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()

func _on_hurt_box_hurt(damage):	
	hp -= damage
	print(hp)

# Loading ammo
func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo
	iceSpearAttackTimer.start()

# Shooting ammo
func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()
		
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body: Node2D):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body: Node2D):
	if enemy_close.has(body):
		enemy_close.erase(body)
