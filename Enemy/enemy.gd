extends CharacterBody2D

# export makes movement speed adjustable in editor
@export var movement_speed = 20.0
@export var hp = 10
@export var knockback_recovery = 3.5
@export var experience = 1
var knockback = Vector2.ZERO

# var gets values after all nodes loaded. Used to reference nodes
@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var snd_hit = $snd_hit

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/experience_gem.tscn")

signal remove_from_array(object)

func _ready():
	anim.play("walk")

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	# set vector towards players x/y position // direction_to normalizes vector
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < 0.1:
		sprite.flip_h = false


func _on_hurt_box_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount # set knockback to opposite of traversing vector of ice spear angle
	if hp <= 0:
		death()
	else: 
		snd_hit.play() # take a hit w/ noise

func death():
	emit_signal("remove_from_array", self) # clean up from hit array
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death) #spawn death animation on parent of enemy
	
	#spawn experience gem
	var new_gem = exp_gem.instantiate()
	new_gem.global_positoin = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	
	queue_free() # removes object from the game
	
