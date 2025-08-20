extends CharacterBody2D

var current_screen := Vector2.ZERO

var collision_cooldown = 0
var invuln_timer = 0 #checking if lots of collisions in a row
var successive_collisions = 0 #3 non-damaging collisions or one damaging collision grant invulnerability
var invulnerable = false
var zapped = false
var zap_timer = 0

@onready var sonar = $SonarEmitter

var max_health := 1000
var current_health := max_health
@onready var health_bar := $HealthBar
@onready var red_screen := $Camera2D/RedScreen

var facing_right = true
var light_angle = 0

var max_depth = 200
var current_depth = 0
@onready var max_depth_value = $"Camera2D/Control/Max Depth Value"
@onready var current_depth_value = $"Camera2D/Control/Current Depth Value"

var powered = true
var sonar_enabled = true

@onready var dirty_sprite = $DirtySprite
@onready var clean_sprite = $CleanSprite
var current_sprite

var pirate_mode_ready = false
@onready var pirate_sprite = $PirateSprite

func _ready() -> void:
	SignalBus.submarine_power_off.connect(_on_power_off)
	SignalBus.sonar_enabled.connect(_switch_navigation)
	current_sprite = clean_sprite
	
func _physics_process(delta):

	if powered:
		move_sprite()
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		velocity.y = move_toward(velocity.y, 0, deceleration * delta)
		if current_sprite.is_playing():
			current_sprite.stop()
			
		
	move_and_handle_collisions(delta)
	
func _process(delta):
	

	#pirate
	if pirate_mode_ready:
		if Input.is_action_just_pressed("interact"):
			current_sprite.visible = false
			current_sprite = pirate_sprite
			current_sprite.visible = true
	#
	
	light(delta)
	collision_cooldown = max(collision_cooldown - delta, 0)
	
	invuln_timer = max(invuln_timer - delta, 0)
	if invuln_timer <= 0:
		successive_collisions = 0
		invulnerable = false
		
	zap_timer = max(zap_timer - delta, 0)
	if zap_timer <= 0:
		zapped = false
	
	var anim = "default"

	if dash_cooldown_timer > dash_cooldown/2:
		anim = "dash"
	elif zapped:
		anim = "zapped"
	elif invulnerable:
		anim = "invulnerable"

	if current_sprite.animation != anim:
		current_sprite.animation = anim
		current_sprite.play()
	
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


func move_sprite():
	if velocity.length() > 0:
		current_sprite.play()
	
		if velocity.x != 0:
			dirty_sprite.flip_h = velocity.x < 0
			clean_sprite.flip_h = velocity.x < 0
			pirate_sprite.flip_h = velocity.x < 0
			
			facing_right = velocity.x > 0
	else:
		if current_sprite.animation == "default" :
			current_sprite.stop()
	
func move_and_handle_collisions(delta):
	if bounce_velocity.length() > 0:
		velocity = bounce_velocity * speed + input_vector * speed
		bounce_velocity.x = move_toward(bounce_velocity.x, 0, delta * 2)
		bounce_velocity.y = move_toward(bounce_velocity.y, 0, delta * 2)
		
	move_and_slide()

	# Collision response
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		
		if collision && collision_cooldown <=0:
			collision_cooldown = 0.1
			
			if invuln_timer <= 0:
				invuln_timer = 2 #using invuln timer to check how many collisions happened within 2 seconds
			
			#if collision.get_collider() is RigidBody2D && successive_collisions:
				#collision.get_collider().apply_impulse(velocity.normalized() * 75)
				#var normal = collision.get_normal()
				#bounce_velocity = velocity.bounce(normal).normalized() + normal.normalized()
				#control_factor = 0 #lose control of movement
			#else: #if object is immovable (ie wall)
				#take_damage(10)  #expermenting with removing wall collision damage
			var collider = collision.get_collider()
			if collider is RigidBody2D && collider.collision_layer & (1 << 5):
				if is_dashing:
					collider.apply_impulse(input_vector.normalized() * speed)
				else:
					collider.apply_impulse(input_vector.normalized() * speed)
			else:
				red_screen.color.a = 0.6
				var normal = collision.get_normal()
				bounce_velocity = velocity.bounce(normal).normalized() + normal.normalized()
				control_factor = 0 #lose control of movement
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
						collider._caught_player()
					
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
	$Light.rotation = lerp_angle($Light.rotation, angle_to_mouse - PI/2, 3 * delta)
		
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
	#if speed < 2000:
	#	speed = 2000
	#	$Light.energy *= 10
	#else:
	#	speed = 500
	#	$Light.energy /= 10
	#max_depth = 1000
	
	if $Light.energy == 0:
		$Light.energy = 1
	else:
		$Light.energy = 0
	
