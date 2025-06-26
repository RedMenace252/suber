extends Node

@onready var main_2d = $Scene2D
@onready var main_3d = $Scene3D
@onready var player2d = $Scene2D/Player2D
var player3dtemplate = preload("res://src/player_3d/player_3d.tscn")
var player3d
var player3danimator

var in_3d_mode = false
var is_switching = false

func _ready():
	RenderingServer.set_default_clear_color(Color(0, 0, 0))
	SignalBus.emit_signal("fade_in")
	await get_tree().create_timer(1.0).timeout
	#SignalBus.emit_signal("display_dialogue", "intro")


func _input(event):
	if event.is_action_pressed("toggle_cockpit"):
		toggle_view_mode()

func toggle_view_mode():
	if is_switching:
		return  # Ignore rapid toggles
		
	in_3d_mode = !in_3d_mode

	if in_3d_mode:
		exit_2d()
	else:
		exit_3d()
		
func exit_2d():
	is_switching = true
	player2d.set_process(false)
	player2d.set_physics_process(false)
	player2d.set_process_input(false)
	SignalBus.emit_signal("fade_out")
	await get_tree().create_timer(1.0).timeout
	main_2d.visible = false
	enter_3d()
	
func exit_3d():
	is_switching = true
	player3d.mouse_look_enabled = false
	player3d.set_process(false)
	player3d.set_physics_process(false)
	player3d.set_process_input(false)
	SignalBus.emit_signal("fade_out")
	await get_tree().create_timer(1.0).timeout
	player3d.queue_free()
	main_3d.visible = false
	enter_2d()
	
func enter_2d():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	main_2d.visible = true
	SignalBus.emit_signal("fade_in")
	await get_tree().create_timer(1.0).timeout
	player2d.set_process(true)
	player2d.set_physics_process(true)
	player2d.set_process_input(true)
	is_switching = false
	
func enter_3d():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	main_3d.visible = true
	player3d = player3dtemplate.instantiate()
	main_3d.add_child(player3d)
	player3danimator = player3d.get_node("Player3DAnimator")
	player3d.set_process(false)
	player3d.set_physics_process(false)
	player3d.set_process_input(false)
	player3d.mouse_look_enabled = false
	SignalBus.emit_signal("fade_in")
	player3danimator.play("periscope_out")
	await player3danimator.animation_finished
	player3d.set_process(true)
	player3d.set_physics_process(true)
	player3d.set_process_input(true)
	player3d.mouse_look_enabled = true
	is_switching = false
