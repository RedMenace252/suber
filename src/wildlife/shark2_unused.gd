extends CharacterBody2D

enum SharkStateEnum {
	IDLE,
	CHASE,
	ATTACK,
	REST
}

var shark_state = SharkStateEnum.IDLE
var speed = 0
var turn_speed = 0

var direction = Vector2(0, 0)
var target_direction = Vector2(0,0)

@export var top_left_bound: Vector2
@export var bottom_right_bound: Vector2

var direction_timer = 0

var sprite_direction = Vector2.RIGHT

func _ready() -> void:
	shark_state = SharkStateEnum.IDLE
	
	if top_left_bound == Vector2(0,0) && bottom_right_bound == Vector2(0,0):
		var screen_size := get_viewport_rect().size
		top_left_bound = (global_position/screen_size).floor() * screen_size
		bottom_right_bound = top_left_bound + screen_size
		
	top_left_bound += Vector2(30,30)
	bottom_right_bound -= Vector2(30,30)
	
func _physics_process(delta: float) -> void:
	match shark_state:
		SharkStateEnum.IDLE:
			idle(delta)
			
func idle(delta):
	speed = move_toward(speed, 100, delta * 50)
	turn_speed = move_toward(turn_speed, 100, delta * 1)
	
	direction_timer += delta
	if direction_timer >= 10:
		direction = randf_range(0,8)
		var angle_change = deg_to_rad(randf_range(0, 360))
		target_direction = direction.rotated(angle_change).normalized()
		
	if direction.x >= 0:
		sprite_direction = Vector2.RIGHT
	else:
		sprite_direction = Vector2.LEFT
		
	$AnimatedSprite2D.flip_v = sprite_direction == Vector2.LEFT
	
	direction = direction.slerp(target_direction.normalized(), turn_speed * delta).normalized()
	
	velocity = direction.normalized() * speed
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		direction = direction.bounce(collision.get_normal()).normalized()

	rotation = direction.angle()
	
	if global_position.x - top_left_bound.x < 30:
		direction *= -1
	if global_position.y - top_left_bound.y < 30:
		direction *= -1
	if bottom_right_bound.x - global_position.x < 30:
		direction *= -1
	if bottom_right_bound.y - global_position.y < 30:
		direction *= -1
	
		 
