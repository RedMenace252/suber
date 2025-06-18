extends CharacterBody2D

var current_screen := Vector2.ZERO

@export var speed = 500
var above_water = false
var gravity_velocity = 0
var bounce_velocity = Vector2(0,0)

@onready var sonar = $SonarEmitter

@export var max_health := 100
var current_health := max_health
@onready var health_bar := $HealthBar
@onready var red_screen := $Camera2D/RedScreen

var facing_right = true
var light_angle = 0

var max_depth = 2
var current_depth = 0
@onready var max_depth_value = $"Camera2D/Control/Max Depth Value"
@onready var current_depth_value = $"Camera2D/Control/Current Depth Value"

func _physics_process(delta):
	velocity = Vector2(0,0)
	
	movement_input(delta)
	gravity(delta)
	
	move_sprite()
	
	move_and_handle_collisions(delta)
	
func _process(delta):
	
	light(delta)
	
	current_depth = position.y / 1080
	
	if current_depth > max_depth:
		take_damage(1)
		red_screen.color.a = 0.2
		current_depth_value.label_settings.font_color = Color.CRIMSON
	else:
		current_depth_value.label_settings.font_color = Color.WHITE
		
	max_depth_value.text = str(round(max_depth * 25))
	current_depth_value.text = str(round(current_depth * 25))
	
	red_screen.color.a = move_toward(red_screen.color.a, 0, delta * 2)
		
	
func movement_input(delta):
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1

	input_vector = input_vector.normalized()
	
	velocity = input_vector * speed

func gravity(delta):
	if above_water:
		velocity.y = - speed + gravity_velocity
		gravity_velocity += delta * speed * 2
	else:
		if gravity_velocity > speed:
			velocity.y = - speed + gravity_velocity
			gravity_velocity -= delta * speed * 6
		else:
			gravity_velocity = 0
			
	clamp(velocity.y, - speed, speed)

func move_sprite():
	if velocity.length() > 0:
		$Sprite.play()
	
		if velocity.x != 0:
			$Sprite.flip_h = velocity.x < 0
			facing_right = velocity.x > 0
	else:
		$Sprite.stop()
	
func move_and_handle_collisions(delta):
	if bounce_velocity.length() > 0:
		velocity = bounce_velocity * speed
		bounce_velocity.x = move_toward(bounce_velocity.x, 0, delta * 2)
		bounce_velocity.y = move_toward(bounce_velocity.y, 0, delta * 2)
		
		if gravity_velocity > 0:
			velocity.y += (- speed + gravity_velocity)/2
		
	move_and_slide()

	# Collision response
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		if collision:
			take_damage(20)
			red_screen.color.a = 0.6
			bounce_velocity = collision.get_normal()
			
	
	
func light(delta):
	if Input.is_action_pressed("light_up"):
		light_angle -= delta
	if Input.is_action_pressed("light_down"):
		light_angle += delta	
	
	light_angle = clamp(light_angle, -PI/6, PI/3)
		
	if facing_right:
		$Light.position.x = 70
		$Light.rotation = light_angle
	else:
		$Light.position.x = -70
		$Light.rotation = PI - light_angle
		
func _input(event):
	if Input.is_action_just_pressed("ping_sonar"):
		sonar.emit_sonar()
		
	#test############################################################
	if Input.is_action_just_pressed("test_key"):
		do_test()
		

func set_current_screen(screen: Vector2):
	current_screen = screen

func take_damage(amount: float):
	current_health = max(current_health - amount, 0.0)
	health_bar.value = current_health
	
	if current_health <= 0:
		die()
		
func die(): #expand later
	red_screen.color.a = 0.6
	get_tree().reload_current_scene()
		
		
		
		
		
####################################################################
func do_test():
	SignalBus.emit_signal("display_dialogue", "test1")
