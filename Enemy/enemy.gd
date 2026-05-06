extends CharacterBody2D

# export makes movement speed adjustable in editor
@export var movement_speed = 20.0

# var gets values after all nodes loaded. Used to reference nodes
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer

func _ready():
	anim.play("walk")

func _physics_process(_delta):
	# set vector towards players x/y position // direction_to normalizes vector
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < 0.1:
		sprite.flip_h = false
