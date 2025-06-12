extends CharacterBody3D

@export var move_speed := 2.0
@export var mouse_sensitivity := 0.002

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D

var y_rotation := 0.0  # Yaw
var x_rotation := 0.0  # Pitch
var mouse_look_enabled := false

func _ready():
	mouse_look_enabled = false
	
func _input(event):
	if event is InputEventMouseMotion and mouse_look_enabled:
		y_rotation -= event.relative.x * mouse_sensitivity
		x_rotation -= event.relative.y * mouse_sensitivity
		x_rotation = clamp(x_rotation, deg_to_rad(-90), deg_to_rad(90))

		rotation.y = y_rotation
		camera_pivot.rotation.x = x_rotation

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left_3d", "move_right_3d", "move_forward_3d", "move_backward_3d")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z  * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.y = move_toward(velocity.y, 0, move_speed)
		
	if input_dir == Vector2(0, 0):
		velocity = Vector3(0, 0, 0)
		
	move_and_slide()
