extends Node2D

@export var num_rays: int = 1000
@export var dot_scene: PackedScene = preload("res://src/player/sonar_dot.tscn") # Preloaded dot scene to instance


func emit_sonar():
	var origin = global_position

	for i in num_rays:
		var angle = (TAU / num_rays) * i
		var direction = Vector2.RIGHT.rotated(angle)
		
		var dot = dot_scene.instantiate()
		get_tree().current_scene.add_child(dot)

		dot.global_position = origin
		dot.move_direction = direction

		
