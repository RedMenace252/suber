extends CharacterBody2D

@onready var screen_size : Vector2 = get_viewport_rect().size

var direction : Vector2 = Vector2(0,0)
var speed : float = 0
var impulse_speed : float = 2
var impulse_timer : float
var impulse_cooldown : float= 15
var hazard : bool = false

var screen : Vector2

func _ready() -> void:
	screen =  (global_position / screen_size).floor()
	impulse_timer = randf() * impulse_cooldown
	
	if get_parent().z_index <= -500:
		collision_layer -= 8
	else:
		hazard = true
	
func _physics_process(delta: float) -> void:
	impulse_timer += delta
	
	if impulse_timer >= impulse_cooldown:
		impulse_timer = 0 + randf_range(-0.5,0.5)
		direction = Vector2.UP.rotated(randf() * TAU) 
		speed = impulse_speed
		
	rotation = direction.angle()
	
	if speed > 0:
		speed -= impulse_speed * delta
		if hazard:
			$AnimatedSprite2D.play("electric_propel")
		else:
			$AnimatedSprite2D.play("propel")
	else:
		speed = 0
		if hazard:
			$AnimatedSprite2D.play("electric")
		else:
			$AnimatedSprite2D.play("idle")
	
	velocity = speed * direction.normalized()
	
	var collision = move_and_collide(velocity)
	
	if collision:
		direction = direction.bounce(collision.get_normal()).normalized()
	
	bounce_off_screen_bounds()

func bounce_off_screen_bounds():
	var bounced = false
	
	var bound_left = screen.x * screen_size.x + 100
	var bound_right = (screen.x + 1) * screen_size.x - 100
	var bound_top = screen.y * screen_size.y + 100
	var bound_bottom = (screen.y + 1) * screen_size.y - 100

	if global_position.x <= bound_left or global_position.x >= bound_right:
		direction.x *= -1
		global_position.x = clamp(global_position.x, bound_left, bound_right)
		bounced = true

	if global_position.y <= bound_top or global_position.y >= bound_bottom:
		direction.y *= -1
		global_position.y = clamp(global_position.y, bound_top, bound_bottom)
		bounced = true

	return bounced
