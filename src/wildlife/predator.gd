extends CharacterBody2D

var start_pos : Vector2
var detection_area : Area2D
var target : CharacterBody2D
var on_screen_notifier : VisibleOnScreenNotifier2D

var speed : float = 0
@export var max_speed : float = 1000
@export var acceleration : float = 200

var chasing : bool = false

func _ready():
	start_pos = global_position
	detection_area = $DetectionArea
	on_screen_notifier = $VisibleOnScreenNotifier2D
	
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	on_screen_notifier.screen_exited.connect(_stop_chase)

func _process(delta):
	var goal : Vector2
	
	if chasing:
		speed = move_toward(speed, max_speed, acceleration * delta)
		goal = target.global_position
	elif (global_position - start_pos).length() < 10:
		speed = move_toward(speed, 1, acceleration * delta)
		goal = start_pos
	else: 
		speed = 0
		global_position = start_pos
		
	var direction = (goal - global_position).normalized()
	
	###wave
	var perpendicular = Vector2(-direction.y, direction.x)
	# Sine wave offset
	var wave_frequency = 4.0  # controls how fast it wiggles
	var wave_offset = perpendicular * sin(Time.get_ticks_msec() / 1000.0 * wave_frequency)
	
	goal += wave_offset * 100
	direction = (goal - global_position).normalized()
	
	velocity = direction * speed
	rotation = velocity.angle()
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player2D":
		target = body
		chasing = true
		set_collision_layer_value(5, true)

func _stop_chase():
	chasing = false
	set_collision_layer_value(5, false)
	target = null

func _caught_player():
	_stop_chase()
	
