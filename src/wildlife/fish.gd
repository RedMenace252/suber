extends CharacterBody2D

@export var speed = 80
var direction = Vector2.RIGHT.rotated(randf() * TAU)

var above_water = false
var gravity_velocity = 0

func _physics_process(delta):
	var motion = direction * speed * delta
	
	if above_water:
		motion.y = gravity_velocity * delta
		gravity_velocity += speed * delta * 2
		
		direction.y = 0
	else:
		gravity_velocity -= speed * delta * 2
		gravity_velocity = max(- speed, gravity_velocity)
		
	if gravity_velocity > - speed:
		motion.y = gravity_velocity * delta
	
	var collision = move_and_collide(motion)
	
	if collision:
		direction = direction.bounce(collision.get_normal()).normalized()

	if randi() % 100 < 2:
		var angle_change = deg_to_rad(randf_range(-90.0, 90.0))
		direction = direction.rotated(angle_change).normalized()

	if direction.x != 0:
		$Sprite.flip_h = direction.x > 0
