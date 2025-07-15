extends CharacterBody2D

class_name Whale

var current_direction = Vector2.RIGHT
var target_direction = Vector2.RIGHT
var speed = 25
var above_water = false

var base_direction = Vector2.RIGHT
var direction_timer = 0.0
var direction_cooldown = 15.0
var turn_speed = 0.05
var angle_offset = 0

var undulation_amplitude = 0.5
var undulation_frequency = 0.3
var undulation_offset = 0

var turn_around_chance = 0.1  # 10% chance to flip direction
@export var child = false
@export var parent_whale: Whale

func _ready():
	direction_timer = randf() * direction_cooldown
	undulation_offset = randf() * (1/undulation_frequency)

func _physics_process(delta):
	direction_timer += delta

	if direction_timer >= direction_cooldown:
		
		direction_timer = 0 + randf_range(- direction_cooldown, direction_cooldown)

		angle_offset += deg_to_rad(randf_range(-15, 15))
		target_direction = base_direction.rotated(angle_offset).normalized()

	if child:
			target_direction = parent_whale.global_position - global_position
			if target_direction.length() < 300:
				speed = 15
			else:
				speed = 30
			
	if above_water:
		target_direction = base_direction.normalized() + Vector2.DOWN.normalized()
		
	# Determine base direction (horizontal)
	if current_direction.x >= 0:
		base_direction = Vector2.RIGHT
	else:
		base_direction = Vector2.LEFT
		
	# Flip sprite base_directiond on base_direction direction (look ahead)
	$AnimatedSprite2D.flip_v = base_direction == Vector2.LEFT
			
	# Smooth turn toward target
	current_direction = current_direction.slerp(target_direction, turn_speed * delta).normalized()

	#MAYBEEEEEE:
	# Undulation
	var time = Time.get_ticks_msec() / 1000.0
	var sine_wave = sin(time * TAU * undulation_frequency + undulation_offset)
	var perp = Vector2(-current_direction.y, current_direction.x)
	var undulation = perp * sine_wave * undulation_amplitude

	var move_direction = (current_direction + undulation).normalized()
	###############
	
	velocity = move_direction * speed

	# Movement and gentle bounce
	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.get_normal()
		target_direction = current_direction.bounce(normal).slerp(normal, 0.2).normalized()
		base_direction = - base_direction
		angle_offset = 0
		
		# yeah yeah this is chatgpt ass code i know i know
		var angle_between = current_direction.normalized().angle_to(base_direction.normalized())
	
		# ⏱️ If it's nearly aligned (within 15 degrees), flip current_direction.x
		if abs(angle_between) < deg_to_rad(15):
			current_direction.x = -current_direction.x  # Flip horizontally
		#mr gpt is a very good helper and i like him very much

	# Rotate whale to match movement direction
	rotation = current_direction.angle()
