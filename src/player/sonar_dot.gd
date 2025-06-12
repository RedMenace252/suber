extends Node2D

@export var lifetime: float = 5
@export var move_speed: float = 500.0
@export var collision_mask: int = 5 #layer 1 and 3

@export var move_direction: Vector2 = Vector2.ZERO

var elapsed_time := 0.0

func _process(delta):
	elapsed_time += delta

	# Move outward
	if move_direction != Vector2.ZERO:
		var motion = move_direction * move_speed * delta
		var target_position = global_position + motion
		var result = get_world_2d().direct_space_state.intersect_ray(
			PhysicsRayQueryParameters2D.create(global_position, target_position, collision_mask)
		)

		if result:
			global_position = result.position
			move_direction = Vector2.ZERO
		else:
			global_position = target_position

	var modulate = self.modulate
	modulate.a = lerp(1.0, 0.0, elapsed_time / lifetime)
	self.modulate = modulate

	if elapsed_time >= lifetime:
		queue_free()
