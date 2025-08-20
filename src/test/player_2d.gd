extends CharacterBody2D

#basic movement + player input
var speed : float = 600
var player_input : Vector2 = Vector2.ZERO
var player_velocity : Vector2 = Vector2.ZERO
var player_acceleration_time : float = 0.1 #time in s to accelerate to max speed
var control_factor : Vector2 = Vector2.ONE

#gravity
var above_water : bool = false
var in_water : bool = true
var gravity_acceleration : float = 980
var buoyancy_acceleration_time : float = 0.3
var buoyancy_acceleration : float = 0
var gravity_velocity : Vector2 = Vector2.ZERO

#external input (movement)
var external_target_velocity : Vector2 = Vector2.ZERO
var external_acceleration : float = 0
var external_velocity : Vector2 = Vector2.ZERO

#dash
var is_dashing : bool = false
var can_dash : bool = true
var chain_dash_timing_missed : bool = false
var dash_timer : float = 0
var dash_duration : float = 0.3
var chain_window : float = 0.2
var dash_cooldown_timer : float = 0
var dash_cooldown : float = 1
var dash_speed : float = 2000
var dash_direction : Vector2 = Vector2.ZERO
var dash_velocity : Vector2 = Vector2.ZERO

#collisions


#submarine status
var invulnerable : bool = false
var invuln_timer : float = 0
var zapped : bool = false
var zap_timer : float = 0

#sprite control
@onready var sprite_controller : Node2D = $Sprite
var facing_right : bool = true

#sonar
@onready var sonar = $SonarEmitter

#camera
@onready var red_screen := $Camera2D/RedScreen

#extras
var pirate_mode_ready : bool = false


func _process(delta: float) -> void:
	$Bubbles.direction = -velocity.normalized()
	
	_control_sprite()
	_light(delta)
	_process_inputs()
	
	invuln_timer = max(invuln_timer - delta, 0)
	if invuln_timer <= 0:
		invulnerable = false
		
	zap_timer = max(zap_timer - delta, 0)
	if zap_timer <= 0:
		zapped = false
	
	red_screen.color.a = move_toward(red_screen.color.a, 0, delta * 2)
	
func _control_sprite():
	if facing_right and velocity.x < 0:
		facing_right = false
		scale.x *= -1
	elif !facing_right and velocity.x > 0:
		facing_right = true
		scale.x *= -1
		
	if zapped:
		sprite_controller._set_animation("zapped")
	elif invulnerable:
		sprite_controller._set_animation("invulnerable")
	elif is_dashing:
		sprite_controller._set_animation("dash")
	else:
		sprite_controller._set_animation("default")
		if player_input.length() == 0:
			sprite_controller.playing = false
		else:
			sprite_controller.playing = true
	
	#pirate sprite
	if pirate_mode_ready and Input.is_action_just_pressed("interact"):
		sprite_controller.switch_sprite("PirateSprite")

func _light(delta):
	var global_mouse_pos = get_global_mouse_position()
	var light_global_pos = $Light.global_position

	# Calculate angle from light to mouse
	var angle_to_mouse = (global_mouse_pos - light_global_pos).angle()

	# Determine facing direction, flip light position if needed
	$Light.rotation = lerp_angle($Light.rotation, angle_to_mouse - PI/2, 3 * delta)

func _process_inputs():
	if Input.is_action_just_pressed("ping_sonar"):
		sonar.emit_sonar()
		
	#test############################################################
	if Input.is_action_just_pressed("test_key"):
		do_test()

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	control_factor = control_factor.move_toward(Vector2.ONE, delta)
	if zapped:
		control_factor = Vector2(0.1,0.1)
	_process_player_input(delta)
	_process_gravity(delta)
	_process_external_input(delta)
	_process_dash(delta)
	if is_dashing:
		velocity = dash_velocity
	else:
		velocity = player_velocity
	
	velocity += external_velocity + gravity_velocity
	move_and_slide()
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		_process_collisions(collision)
		
	#control_factor = Vector2(clamp(control_factor.x, 0, 1),clamp(control_factor.y, 0, 1))
	#total_input = player_input * control_factor + external_input
	#var target_velocity : Vector2 = total_input * speed
	#velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	#velocity.y = move_toward(velocity.y, target_velocity.y, acceleration * delta)
	
func _process_player_input(delta: float):
	player_input = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	var player_acceleration : float = speed / player_acceleration_time
	
	player_input *= control_factor
	player_acceleration *= control_factor.length()
	
	player_velocity = player_velocity.move_toward(player_input * speed, player_acceleration * delta)

func _process_gravity(delta: float):
	if above_water && !is_dashing:
		if in_water:
			in_water = false
			gravity_velocity.y += player_velocity.y #little jump outta water
		control_factor.y = 0
		if player_velocity.y < 0:
			player_velocity.y += delta * gravity_acceleration
		else: 
			player_velocity.y = 0
			gravity_velocity.y += delta * gravity_acceleration
	else: 
		if in_water == false:
			in_water = true
			buoyancy_acceleration = gravity_velocity.y / buoyancy_acceleration_time
		if gravity_velocity.y > 0:
			gravity_velocity.y -= delta * buoyancy_acceleration
		else:
			gravity_velocity.y = 0

func _external_input(velocity_change : Vector2, acceleration_time : float):
	external_target_velocity += velocity_change 
	external_acceleration = velocity_change.length() / acceleration_time

func _process_external_input(delta: float):
	external_velocity =  external_velocity.move_toward(external_target_velocity, external_acceleration * delta)

func _process_dash(delta: float):
	dash_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if is_dashing:
		$Bubbles.emitting = true
		dash_timer -= delta
		dash_velocity *= 0.96
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = dash_cooldown
			dash_velocity = Vector2.ZERO
		can_dash = false
		if Input.is_action_just_pressed("dash"):
			chain_dash_timing_missed = true
	elif dash_cooldown_timer >= dash_cooldown - chain_window:
		$Bubbles.emitting = false
		if !chain_dash_timing_missed && !above_water:
			$Sprite.modulate = Color(1.5,1.5,1.5)
			can_dash = true
	elif dash_cooldown_timer > 0:
		can_dash = false
		chain_dash_timing_missed = false
		$Sprite.modulate = Color(1,1,1)
	else:
		can_dash = !above_water
		
	dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)
	
	if Input.is_action_just_pressed("dash") and dash_direction.length() > 0 and can_dash:
		start_dash(dash_direction)

func start_dash(dash_direction: Vector2):
	is_dashing = true
	dash_timer = dash_duration
	dash_velocity = dash_speed * dash_direction

func _process_collisions(collision : KinematicCollision2D):
	var collider = collision.get_collider()
	if collider is TileMapLayer:
		pass
	elif collider is RigidBody2D && collider.collision_layer & (1 << 5):
		collider.apply_impulse(collision.get_normal() * 30 * -1)
	elif collider is CharacterBody2D:
		if collider.collision_layer & (1 << 3): #is collider on collision layer 4 (hazards)
			zapped = true
			zap_timer = 1
			invulnerable = true
			invuln_timer = 2
			player_velocity = speed * velocity.bounce(collision.get_normal()).normalized()
		if collider.collision_layer & (1 << 4): #is collider on collision layer 5 (predators)
			red_screen.color.a = 0.6
			invulnerable = true
			invuln_timer = 1
			control_factor = Vector2.ZERO
			collider._caught_player()

func set_current_screen(screen : Vector2):
	pass

func do_test():
	pass
