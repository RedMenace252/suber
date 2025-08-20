extends CharacterBody2D

@export var top_left_bound: Vector2
@export var bottom_right_bound: Vector2

@export var speed = 100
var turn_speed = 3
var acceleration = 100
var chase_range = 750

var current_direction = Vector2.RIGHT
var target_direction = Vector2.RIGHT
var direction_timer = 0.0
var direction_cooldown = 5.0

var sprite_direction = Vector2.RIGHT

var target

func _ready():
	direction_timer = randf() * direction_cooldown
	
	if top_left_bound == Vector2(0,0) && bottom_right_bound == Vector2(0,0):
		var screen_size := get_viewport_rect().size
		top_left_bound = (global_position/screen_size).floor() * screen_size
		bottom_right_bound = top_left_bound + screen_size
		
	top_left_bound += Vector2(30,30)
	bottom_right_bound -= Vector2(30,30)
	
	chase_range = 750 * (bottom_right_bound.x - top_left_bound.x) / 1920
	
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
		
	# Flip sprite_direction with direction
	#if sprite_direction == Vector2.LEFT:
	#	scale.x = -1
	#else:
	#	scale.x = 1
	
	if target != null:
		target_direction = target.global_position - global_position
		speed = move_toward(speed, 400, delta * acceleration)
		turn_speed = move_toward(turn_speed, 10, delta * 2)
	else:
		speed = move_toward(speed, 100, delta * acceleration)
		turn_speed = move_toward(turn_speed, 3, delta * 2)
		
	if target:
		if target_direction.length() >= chase_range:
			target = null #distance check
	
	if target:		
		if target.global_position.x < top_left_bound.x or target.global_position.y < top_left_bound.y or \
			target.global_position.x > bottom_right_bound.x or target.global_position.y > bottom_right_bound.y:
			target = null #target in area check
		
	current_direction = current_direction.normalized() #just in case?
	
	# Smooth turn toward target
	current_direction = current_direction.slerp(target_direction.normalized(), turn_speed * delta).normalized()
	
	velocity = current_direction.normalized() * speed #i know i dont need to keep normalising but its being weird

	# Movement and gentle bounce
	var collision = move_and_collide(velocity * delta)
	if collision:
		current_direction = current_direction.bounce(collision.get_normal()).normalized()

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
	
func caught_player():
	target = null
	target_direction *= -1

func _on_detection_radius_body_entered(body: Node2D) -> void:
	if body.name == "Player2D":
		turn_speed = 3
		target = body
