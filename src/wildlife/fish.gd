extends CharacterBody2D

@export var speed = 80
var direction = Vector2.RIGHT.rotated(randf() * TAU)

func _physics_process(delta):
	var motion = direction * speed * delta
	var collision = move_and_collide(motion)
	
	if collision:
		direction = direction.bounce(collision.get_normal()).normalized()

	if randi() % 100 < 2:
		var angle_change = deg_to_rad(randf_range(-15.0, 15.0))
		direction = direction.rotated(angle_change).normalized()

	if direction.x != 0:
		$Sprite.flip_h = direction.x > 0
