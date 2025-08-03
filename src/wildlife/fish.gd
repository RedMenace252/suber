extends CharacterBody2D

@onready var screen_size := get_viewport_rect().size
var screen

var current_direction = Vector2.RIGHT
var target_direction = Vector2.RIGHT
@export var speed = 100
var above_water = false

var sprite_direction = Vector2.RIGHT
var direction_timer = 0.0
var direction_cooldown = 5.0
var turn_speed = 1

func _ready():
	screen =  (global_position / screen_size).floor()
	direction_timer = randf() * direction_cooldown

func _physics_process(delta):
	direction_timer += delta

	if direction_timer >= direction_cooldown:
		
		direction_timer = 0 + randf_range(- direction_cooldown, direction_cooldown)

		var angle_change = deg_to_rad(randf_range(0, 360))
		target_direction = current_direction.rotated(angle_change).normalized()
		
		if randf() < 0.2:
			current_direction.x *= -1
			
	if above_water:
		current_direction.y = 1
		
	# Determine base direction (horizontal)
	if current_direction.x >= 0:
		sprite_direction = Vector2.RIGHT
	else:
		sprite_direction = Vector2.LEFT
		
	# Flip sprite_direction with direction
	$AnimatedSprite2D.flip_v = sprite_direction == Vector2.LEFT
	
	# Smooth turn toward target
	current_direction = current_direction.slerp(target_direction, turn_speed * delta).normalized()
	
	velocity = current_direction.normalized() * speed

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
	
	var bound_left = screen.x * screen_size.x + 30
	var bound_right = (screen.x + 1) * screen_size.x - 30
	var bound_top = screen.y * screen_size.y + 30
	var bound_bottom = (screen.y + 1) * screen_size.y - 30

	if global_position.x <= bound_left or global_position.x >= bound_right:
		target_direction.x *= -1
		current_direction *= -1
		global_position.x = clamp(global_position.x, bound_left, bound_right)
		bounced = true

	if global_position.y <= bound_top or global_position.y >= bound_bottom:
		target_direction.y *= -1
		current_direction *= -1
		global_position.y = clamp(global_position.y, bound_top, bound_bottom)
		bounced = true

	return bounced
