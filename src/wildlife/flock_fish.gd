extends CharacterBody2D

@export var speed: float = 100.0
@export var turn_speed: float = 1.5
@export var separation_distance: float = 30.0
@export var separation_weight: float = 1.5
@export var alignment_weight: float = 1.0
@export var cohesion_weight: float = 1.0

var goal_dir

@onready var screen_size := get_viewport_rect().size
var screen

var current_direction = Vector2.RIGHT
var above_water = false
var sprite_direction = Vector2.RIGHT

# Reference to all other fish
var all_fish: Array = []

func _ready():
	screen = (global_position / screen_size).floor()

func _physics_process(delta):
	var acceleration = Vector2.ZERO

	# Find neighbors
	var neighbors = get_neighbors()

	# Flocking forces
	if neighbors.size() > 0:
		var separation = get_separation(neighbors) * separation_weight
		var alignment = get_alignment(neighbors) * alignment_weight
		var cohesion = get_cohesion(neighbors) * cohesion_weight

		acceleration += separation + alignment + cohesion 
	
	#GOAL DIR NOT IMPLEMENTED YET
	################################
	#################################
	##################################
	############
	#
	#
	#
	#
	############################

	# Add environmental force
	if above_water:
		acceleration.y += 1.0

	acceleration += Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)) * 0.5  # random jitter
	# Smoothly steer
	current_direction = current_direction.slerp(current_direction + acceleration, turn_speed * delta).normalized()

	# Apply movement
	velocity = current_direction * speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		current_direction = current_direction.bounce(collision.get_normal()).normalized()

	# Rotate fish to match direction
	rotation = current_direction.angle()

	# Determine base direction (horizontal)
	if current_direction.x >= 0:
		sprite_direction = Vector2.RIGHT
	else:
		sprite_direction = Vector2.LEFT
		
	# Flip sprite_direction with direction
	$AnimatedSprite2D.flip_v = sprite_direction == Vector2.LEFT

	bounce_off_screen_bounds()

func bounce_off_screen_bounds():
	var bound_left = screen.x * screen_size.x + 30
	var bound_right = (screen.x + 1) * screen_size.x - 30
	var bound_top = screen.y * screen_size.y + 30
	var bound_bottom = (screen.y + 1) * screen_size.y - 30

	if global_position.x <= bound_left or global_position.x >= bound_right:
		current_direction.x *= -1
		global_position.x = clamp(global_position.x, bound_left, bound_right)

	if global_position.y <= bound_top or global_position.y >= bound_bottom:
		current_direction.y *= -1
		global_position.y = clamp(global_position.y, bound_top, bound_bottom)

# Get nearby fish within view radius
func get_neighbors() -> Array:
	var neighbors = []
	for fish in all_fish:
		if fish == self:
			continue
		neighbors.append(fish)
	return neighbors

func get_separation(neighbors: Array) -> Vector2:
	var force = Vector2.ZERO
	for fish in neighbors:
		var to_self = global_position - fish.global_position
		if to_self.length() < separation_distance:
			force += to_self.normalized() / to_self.length()
	return force.normalized()

func get_alignment(neighbors: Array) -> Vector2:
	var avg_dir = Vector2.ZERO
	for fish in neighbors:
		avg_dir += fish.current_direction
	if neighbors.size() > 0:
		avg_dir /= neighbors.size()
	return (avg_dir - current_direction).normalized()

func get_cohesion(neighbors: Array) -> Vector2:
	var center_mass = Vector2.ZERO
	for fish in neighbors:
		center_mass += fish.global_position
	if neighbors.size() > 0:
		center_mass /= neighbors.size()
	return (center_mass - global_position).normalized()
