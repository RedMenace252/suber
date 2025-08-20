extends CharacterBody2D

@export var bounds : Area2D
var top_left_bound: Vector2
var bottom_right_bound: Vector2

@export var speed : float = 0
var turn_speed : float = 0.0

var acceleration : float= 100
var deceleration : float = 300

var chase_timer : float = 0

var current_direction : Vector2
var target_direction : Vector2
var sprite_direction : Vector2 = Vector2.RIGHT

var direction_timer : float = 0.0
var direction_cooldown : float = 15.0

var target : CharacterBody2D
var vector_to_target : Vector2
var potential_target : CharacterBody2D

@onready var light : PointLight2D = $PointLight2D

func _ready():
	direction_timer = randf() * direction_cooldown
	
	#if bounds are not explicitly set, automatically assign them
	if bounds == null:
		var screen_size := get_viewport_rect().size
		top_left_bound = (global_position/screen_size).floor() * screen_size
		bottom_right_bound = top_left_bound + screen_size
	else:
		# Assuming `bounds` is an Area2D node with a CollisionShape2D using RectangleShape2D
		var collision_shape = bounds.get_node("CollisionShape2D")
		var rect_shape = collision_shape.shape as RectangleShape2D
		
		var extents = rect_shape.extents
		var shape_pos = collision_shape.position  # local to Area2D
		
		var global_pos = bounds.global_position + shape_pos
		
		top_left_bound = global_pos - extents + Vector2(30, 30)
		bottom_right_bound = global_pos + extents - Vector2(30, 30)
		
	top_left_bound += Vector2(30,30)
	bottom_right_bound -= Vector2(30,30)
	
	#chase_range *= (bottom_right_bound.x - top_left_bound.x) / 1920
	
func _physics_process(delta):
	direction_timer += delta

	if direction_timer >= direction_cooldown:
		
		direction_timer = 0 + randf_range(- direction_cooldown, direction_cooldown)

		var angle_change = deg_to_rad(randf_range(0, 360))
		target_direction = current_direction.rotated(angle_change).normalized()

		
	# Determine base direction (horizontal)
	if current_direction.x >= 0:
		sprite_direction = Vector2.RIGHT
	else:
		sprite_direction = Vector2.LEFT
		
	# Flip sprite_direction with direction #IMPROVE LATER
	if sprite_direction == Vector2.LEFT:
		scale.y = -abs(scale.y) #IMPROVE LATER
	else:
		scale.y = abs(scale.y)#IMPROVE LATER
	
	if target != null:
		chase_timer += delta
		
		#WAVE MOTION
		vector_to_target = target.global_position - global_position
		var direction = vector_to_target.normalized()

		# Perpendicular vector (90-degree rotation)
		var perpendicular = Vector2(-direction.y, direction.x)

		# Sine wave offset
		var wave_frequency = 4.0  # controls how fast it wiggles
		var wave_magnitude = speed * 2  # controls how wide the wave is
		var wave_offset = perpendicular * sin(Time.get_ticks_msec() / 1000.0 * wave_frequency) * wave_magnitude

		# Add wave offset to direction
		target_direction = (vector_to_target + wave_offset).normalized()

		if vector_to_target.length() >= 2000:
			speed = move_toward(speed, 1000, delta * acceleration * 3)
		elif vector_to_target.length() >= 1000:
			speed = move_toward(speed, 550, delta * acceleration * 2)
		else:
			speed = move_toward(speed, 450, delta * acceleration)
			
		turn_speed = move_toward(turn_speed, 0.5, delta * 2)
		
		light.color.g = move_toward(light.color.g, 0, delta)
		light.color.b = move_toward(light.color.g, 0, delta)
		light.energy = move_toward(light.energy, 1, delta)
	else:
		speed = move_toward(speed, 0, delta * deceleration)
		turn_speed = move_toward(turn_speed, 0.0, delta * 2)
		
		light.color.g = move_toward(light.color.g, 1, delta/10)
		light.color.b = move_toward(light.color.g, 1, delta/10)
		light.energy = move_toward(light.energy, 0, delta)
		
	if potential_target:
		if potential_target.global_position.x > top_left_bound.x or potential_target.global_position.y > top_left_bound.y or \
			potential_target.global_position.x < bottom_right_bound.x or potential_target.global_position.y < bottom_right_bound.y:
				target = potential_target
				start_chase()
		
	if target:
		if target.global_position.x < top_left_bound.x or target.global_position.y < top_left_bound.y or \
			target.global_position.x > bottom_right_bound.x or target.global_position.y > bottom_right_bound.y:
			stop_chase() #bound check	
	
	# Smooth turn toward target
	current_direction = current_direction.slerp(target_direction.normalized(), turn_speed * delta).normalized()
	
	velocity = current_direction.normalized() * speed #i know i dont need to keep normalising but its being weird

	# Movement and gentle bounce
	var collision = move_and_collide(velocity * delta)
	if collision:
		current_direction = current_direction.bounce(collision.get_normal()).normalized()
		target_direction = target_direction.bounce(collision.get_normal()).normalized()

	# Rotate FISH to match movement direction
	rotation = current_direction.angle()
	
	if bounce_off_screen_bounds():
		direction_timer = 0

func bounce_off_screen_bounds():
	var bounced = false
	
	if global_position.x <= top_left_bound.x or global_position.x >= bottom_right_bound.x or\
		global_position.y <= top_left_bound.y or global_position.y >= bottom_right_bound.y:
		target_direction *= -1
		current_direction *= -1
		global_position.x = clamp(global_position.x, top_left_bound.x, bottom_right_bound.x)
		global_position.y = clamp(global_position.y, top_left_bound.y, bottom_right_bound.y)
		bounced = true
	
	return bounced
	
func start_chase():
	#light.energy = 0.01
	#light.color = Color(1,0,0)
	chase_timer = 0
	
func stop_chase():
	target = null 
	#light.energy = .5
	#light.color = Color(1,1,1)
	
func caught_player():
	#stop_chase()
	#potential_target = null
	#target_direction *= -1
	speed -= 300

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player2D":
		potential_target = body
