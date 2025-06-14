extends CharacterBody2D

var current_screen := Vector2.ZERO
@export var speed = 500

@onready var sonar = $SonarEmitter

@export var max_health := 100
var current_health := max_health
@onready var health_bar := $HealthBar

var facing_right = true
var light_angle = 0

var above_water = false
var gravity_velocity = 0


func _physics_process(delta):
	
	move(delta)
	
func _process(delta):
	
	light(delta)
		
func move(delta):
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		$Sprite.play()
		
		# Flip sprite based on horizontal input
		if input_vector.x != 0:
			$Sprite.flip_h = input_vector.x < 0
			facing_right = input_vector.x > 0
	else:
		$Sprite.stop()
	
	velocity = input_vector * speed
	
	if above_water:
		velocity.y = - speed + gravity_velocity
		gravity_velocity += delta * 1000
	else:
		if gravity_velocity > speed:
			velocity.y = - speed + gravity_velocity
			gravity_velocity -= delta * 3000
		else:
			gravity_velocity = 0
			

	move_and_slide()
	
	#damage
	
	if get_slide_collision_count() > 0:
		take_damage(delta * 10)

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
		
	#test
	if Input.is_action_just_pressed("test_key"):
		do_test()
		

func set_current_screen(screen: Vector2):
	current_screen = screen

func take_damage(amount: float):
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health

	if current_health <= 0:
		die()
		
func die(): #expand later
	print("Submarine destroyed!")
	queue_free()

func do_test():
	SignalBus.emit_signal("display_dialogue", "test1")
