extends CharacterBody2D

var current_screen := Vector2.ZERO

@export var speed = 500
var above_water = false
var gravity_velocity = 0
var bounce_velocity = Vector2(0,0)
var input_vector
var control_factor = 1 #how much control the submarine has over movement after a collision
var collision_cooldown = 0
var invuln_timer = 0 #checking if lots of collisions in a row
var successive_collisions = 0 #3 non-damaging collisions or one damaging collision grant invulnerability
var invulnerable = false
var zapped = false
var zap_timer = 0

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
	
	current_sprite = clean_sprite
	
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
	collision_cooldown = max(collision_cooldown - delta, 0)
	
	invuln_timer = max(invuln_timer - delta, 0)
	if invuln_timer <= 0:
		successive_collisions = 0
		invulnerable = false
		
	zap_timer = max(zap_timer - delta, 0)
	if zap_timer <= 0:
		zapped = false
	
	if zapped:
		current_sprite.animation = "zapped"
		current_sprite.play()
	else:
		if invulnerable:
			current_sprite.animation = "invulnerable"
			current_sprite.play()
		else:
			current_sprite.animation = "default"
	
	control_factor = move_toward(control_factor, 1, delta)
	
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

	var control_factor_clamped = clamp(control_factor, 0, 1)
	input_vector = input_vector.normalized() * control_factor_clamped
	
	velocity = input_vector * speed

func gravity(delta):
	if above_water:
		if gravity_velocity == 0:
			if input_vector.y >= 0:
				gravity_velocity = speed
		velocity.y = - speed + gravity_velocity
		gravity_velocity += delta * speed * 2
	else:
		if gravity_velocity > speed:
			velocity.y = - speed + gravity_velocity
			gravity_velocity -= delta * speed * 6
		else:
			gravity_velocity = 0
			
	velocity.y = clamp(velocity.y, - 1.5 * speed, 1.5 * speed)

func move_sprite():
	if velocity.length() > 0:
		current_sprite.play()
	
		if velocity.x != 0:
			dirty_sprite.flip_h = velocity.x < 0
			clean_sprite.flip_h = velocity.x < 0
			facing_right = velocity.x > 0
	else:
		if current_sprite.animation == "default" :
			current_sprite.stop()
	
func move_and_handle_collisions(delta):
	if bounce_velocity.length() > 0:
		velocity = bounce_velocity * speed + input_vector * speed
		bounce_velocity.x = move_toward(bounce_velocity.x, 0, delta * 2)
		bounce_velocity.y = move_toward(bounce_velocity.y, 0, delta * 2)
		
		if gravity_velocity > 0:
			velocity.y += (- speed + gravity_velocity)/2
		
	move_and_slide()

	# Collision response
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		
		if collision && collision_cooldown <=0:
			collision_cooldown = 0.1
			
			if invuln_timer <= 0:
				invuln_timer = 2 #using invuln timer to check how many collisions happened within 2 seconds
			
			if collision.get_collider() is RigidBody2D && successive_collisions: #if object is moveable
				collision.get_collider().apply_impulse(velocity.normalized() * 75)
				var normal = collision.get_normal()
				bounce_velocity = velocity.bounce(normal).normalized() + normal.normalized()
				control_factor = 0 #lose control of movement
			else: #if object is immovable (ie wall)
				#take_damage(10)  #expermenting with removing wall collision damage
				red_screen.color.a = 0.6
				var normal = collision.get_normal()
				bounce_velocity = velocity.bounce(normal).normalized() + normal.normalized()
				control_factor = 0 #lose control of movement
				var collider = collision.get_collider()
				if collider is CharacterBody2D:
					if collider.collision_layer & (1 << 3): #is collider on collision layer 4 (hazards)
						take_damage(10)
						successive_collisions = 3
						zapped = true
						zap_timer = 1
						control_factor = -1
					if collider.collision_layer & (1 << 4): #is collider on collision layer 5 (predators)
						take_damage(15)
						successive_collisions = 3
						control_factor = 0
						collider.target = null
						collider.target_direction *= -1
					
			successive_collisions += 1
			
			if successive_collisions >= 3:
				invulnerable = true
				invuln_timer = 2
				collision_cooldown = 2
			
				
			
	
	
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
		$Light.energy *= 10
	else:
		speed = 500
		$Light.energy /= 10
	max_depth = 1000
