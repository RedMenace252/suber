extends Node

@onready var main_2d = $Scene2D
@onready var main_3d = $Scene3D
@onready var fadeinout  = $Node/FadeInOut/FadeInOutPlayer
@onready var periscopeinout = $Scene3D/Player3D/PlayerAnimator
@onready var player2d = $Scene2D/Submarine
@onready var player3d = $Scene3D/Player3D

var in_3d_mode = false

func _ready():
	player3d.mouse_look_enabled = false
	player3d.set_process(false)
	player3d.set_physics_process(false)
	player3d.set_process_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	fadeinout.play("fade_in")
	#SignalBus.emit_signal("display_dialogue", "intro")


func _input(event):
	if event.is_action_pressed("toggle_cockpit"): #THIS NEEDS TO FREEZE INPUT DURING SCENE SWITCHING
		toggle_view_mode()

func toggle_view_mode():
	in_3d_mode = !in_3d_mode

	if in_3d_mode:
		exit_2d()
	else:
		exit_3d()
		
func exit_2d():
	player2d.set_process(false)
	player2d.set_physics_process(false)
	player2d.set_process_input(false)
	fadeinout.play("fade_out")
	await get_tree().create_timer(1.5).timeout
	main_2d.visible = false
	enter_3d()
	
func exit_3d():
	player3d.mouse_look_enabled = false
	player3d.set_process(false)
	player3d.set_physics_process(false)
	player3d.set_process_input(false)
	fadeinout.play("fade_out")
	await get_tree().create_timer(1.5).timeout
	main_3d.visible = false
	enter_2d()
	
func enter_2d():
	main_2d.visible = true
	fadeinout.play("fade_in")
	await get_tree().create_timer(1).timeout
	player2d.set_process(true)
	player2d.set_physics_process(true)
	player2d.set_process_input(true)
	
func enter_3d():
	main_3d.visible = true
	player3d.position = Vector3(0, 0, 0.4)
	fadeinout.play("fade_in")
	periscopeinout.play("periscope_out")
	await get_tree().create_timer(2).timeout
	player3d.set_process(true)
	player3d.set_physics_process(true)
	player3d.set_process_input(true)
	player3d.mouse_look_enabled = true
