extends CharacterBody2D

var current_screen := Vector2.ZERO

@export var speed = 500
var above_water = false
var gravity_velocity = 0
var bounce_velocity = Vector2(0,0)
var input_vector
var control_factor = 1 #how much control the submarine has over movement after a collision

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

var powered = true
var sonar_enabled = false

@onready var dirty_sprite = $DirtySprite
@onready var clean_sprite = $CleanSprite
var current_sprite

func _ready() -> void:
	SignalBus.submarine_power_off.connect(_on_power_off)
	SignalBus.sonar_enabled.connect(_switch_navigation)
	SignalBus.switch_artstyle.connect(_switch_artstyle)
	
	current_sprite = dirty_sprite
	
func _physics_process(delta):
	
	if powered:
		velocity = Vector2(0,0)
		
		movement_input(delta)
		gravity(delta)
		
		move_sprite()
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		velocity.y = move_toward(velocity.y, 0, speed * delta)
		if current_sprite.is_playing():
			current_sprite.stop()
			
		
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
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

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
			
	velocity.y = clamp(velocity.y, - speed, speed)

func move_sprite():
	if velocity.length() > 0:
		current_sprite.play()
	
		if velocity.x != 0:
			dirty_sprite.flip_h = velocity.x < 0
			clean_sprite.flip_h = velocity.x < 0
			facing_right = velocity.x > 0
	else:
		current_sprite.stop()
	
func move_and_handle_collisions(delta):
	if bounce_velocity.length() > 0:
		velocity = bounce_velocity * speed + input_vector * speed * control_factor
		bounce_velocity.x = move_toward(bounce_velocity.x, 0, delta * 2)
		bounce_velocity.y = move_toward(bounce_velocity.y, 0, delta * 2)
		control_factor = move_toward(control_factor, 1, delta)
		
		if gravity_velocity > 0:
			velocity.y += (- speed + gravity_velocity)/2
		
	move_and_slide()

	# Collision response
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		if collision:
			if collision.get_collider() is RigidBody2D: #if object is moveable (no damage is taken)
				collision.get_collider().apply_impulse(velocity.normalized() * 75)
				var normal = collision.get_normal()
				bounce_velocity = velocity.bounce(normal).normalized() + normal.normalized()
				control_factor = 0 #lose control of movement
			else: #if object is immovable (ie wall)
				take_damage(10)
				red_screen.color.a = 0.6
				var normal = collision.get_normal()
				bounce_velocity = velocity.bounce(normal).normalized() + normal.normalized()
				control_factor = 0 #lose control of movement
			
	
	
func light(delta):
	var global_mouse_pos = get_global_mouse_position()
	var light_global_pos = $Light.global_position

	# Calculate angle from light to mouse
	var angle_to_mouse = (global_mouse_pos - light_global_pos).angle()

	# Determine facing direction, flip light position if needed
	$Light.rotation = lerp_angle($Light.rotation, angle_to_mouse, 3 * delta)
		
func _input(event):
	if Input.is_action_just_pressed("ping_sonar") && sonar_enabled:
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
		
func _on_power_off() -> void:
	powered = false
	speed *= 0.5
	$Light.flicker_light_off()
		
func _switch_navigation() -> void:
	$Light.visible = false
	powered = true
	sonar_enabled = true
	
func _switch_artstyle() -> void:
	dirty_sprite.visible = !dirty_sprite.visible
	clean_sprite.visible = !clean_sprite.visible
	if clean_sprite.visible:
		current_sprite = clean_sprite
	else:
		current_sprite = dirty_sprite
	
		
		
####################################################################
func do_test():
	#SignalBus.emit_signal("display_dialogue", "test1")
	#SignalBus.move_debris.emit()
	if speed < 2000:
		speed = 2000
	else:
		speed = 500
	if $Light.energy < 20:
		$Light.energy = 20
	else:
		$Light.energy = 10
	max_depth = 1000
