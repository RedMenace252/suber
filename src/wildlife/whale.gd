extends CharacterBody2D

var current_direction = Vector2.RIGHT
var target_direction = Vector2.RIGHT
var speed = 25

var base_direction = Vector2.RIGHT
var direction_timer = 0.0
var direction_cooldown = 15.0
var turn_speed = .1

var undulation_amplitude = 0.2
var undulation_frequency = .2

var turn_around_chance = 0.3  # 30% chance to flip direction

func _ready():
	direction_timer = randf() * direction_cooldown

func _physics_process(delta):
	direction_timer += delta

	if direction_timer >= direction_cooldown:
		direction_timer = 0 + randf_range(- direction_cooldown, direction_cooldown)

		# Determine base direction (horizontal)
		if current_direction.x >= 0:
			base_direction = Vector2.RIGHT
		else:
			base_direction = Vector2.LEFT

		# 10% chance to flip direction
		if randf() < turn_around_chance:
			base_direction = -base_direction
			current_direction = Vector2(-current_direction.x, current_direction.y)
			
		# Flip sprite base_directiond on base_direction direction (look ahead)
		$AnimatedSprite2D.flip_v = base_direction == Vector2.LEFT

		# Rotate within ±45° of the horizontal base_direction
		var angle_offset = deg_to_rad(randf_range(-45, 45))
		target_direction = base_direction.rotated(angle_offset).normalized()

	# Smooth turn toward target
	current_direction = current_direction.slerp(target_direction, turn_speed * delta).normalized()

	#MAYBEEEEEE:
	# Undulation
	var time = Time.get_ticks_msec() / 1000.0
	var sine_wave = sin(time * TAU * undulation_frequency)
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

	# Rotate whale to match movement direction
	rotation = current_direction.angle()
