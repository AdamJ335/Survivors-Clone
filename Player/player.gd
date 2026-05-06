extends CharacterBody2D

var movement_speed = 40.0
var hp = 80
@onready var sprite = $Sprite2D
# walkTimer is set as unique path for referencing, rather than calling upon the node within the player
@onready var walkTimer = get_node("%walkTimer")

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


func _on_hurt_box_hurt(damage):	
	hp -= damage
	print(hp)
