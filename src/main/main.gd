extends Node

@onready var main_2d = $Scene2D
@onready var main_3d = $Scene3D
@onready var player2d = $Scene2D/Player2D
var player3dtemplate = preload("res://src/player_3d/player_3d.tscn")
var player3d
var player3danimator

var in_3d_mode = false
var is_switching = false

var first_time_switching = true
var manual_switching_enabled = true


func _ready():
	RenderingServer.set_default_clear_color(Color(0, 0, 0))
	SignalBus.emit_signal("fade_in")
	await get_tree().create_timer(1.0).timeout
	#SignalBus.emit_signal("display_dialogue", "intro")
	SignalBus.toggle_view.connect(toggle_view_mode)

	#########################
	#replace_sprites_recursively(self)

func _input(event):
	if event.is_action_pressed("toggle_cockpit"):
		if manual_switching_enabled:
			toggle_view_mode()
			
	if event.is_action_pressed("switch_artstyle"):
		SignalBus.emit_signal("switch_artstyle")
			
	################test
	#if event.is_action_pressed("test_key"):
		#manual_switching_enabled = true

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
	if first_time_switching:
		first_time_switching = false
		SignalBus.emit_signal("display_dialogue", "view_switch_tutorial_2")
		manual_switching_enabled = true
		
		##########################END OF VERSION 1
		await SignalBus.dialogue_finished
		SignalBus.emit_signal("display_dialogue", "version_1_end")
		await SignalBus.dialogue_finished
		$Scene2D/Player2D.position.x = 13124.0
		$Scene2D/Player2D.position.y = 8268.0
	
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


#######################

@export var placeholder_sprite: Sprite2D
var timer : float = 0.0

func _process(delta):
	timer += delta
	if timer >= 5:
		#replace_sprites_recursively(self)
		timer = 0


func replace_sprites_recursively(node: Node):
	for child in node.get_children():
		if child is Sprite2D and child.texture and placeholder_sprite.texture:
			var old_size = child.texture.get_size()
			var new_size = placeholder_sprite.texture.get_size()
			var original_scale = child.scale

			# Avoid divide-by-zero
			if new_size.x != 0 and new_size.y != 0:
				var scale_factor_x = old_size.x / new_size.x
				var scale_factor_y = old_size.y / new_size.y
				child.scale = Vector2(scale_factor_x * original_scale.x, scale_factor_y * original_scale.y)

			child.texture = placeholder_sprite.texture

		elif child is AnimatedSprite2D and child.sprite_frames and placeholder_sprite.texture:
			# Save existing scale
			var original_scale = child.scale

			# Get size of first frame
			var anims = child.sprite_frames.get_animation_names()
			if anims.size() > 0 and child.sprite_frames.get_frame_count(anims[0]) > 0:
				var old_tex = child.sprite_frames.get_frame_texture(anims[0], 0)
				if old_tex:
					var old_size = old_tex.get_size()
					var new_size = placeholder_sprite.texture.get_size()
					if new_size.x != 0 and new_size.y != 0:
						var scale_factor_x = old_size.x / new_size.x
						var scale_factor_y = old_size.y / new_size.y
						child.scale = Vector2(scale_factor_x * original_scale.x, scale_factor_y * original_scale.y)

			# Replace frames
			var frames = SpriteFrames.new()
			frames.add_animation("default")
			frames.add_frame("default", placeholder_sprite.texture)
			child.sprite_frames = frames
			child.play("default")

		# Recurse into children
		replace_sprites_recursively(child)
