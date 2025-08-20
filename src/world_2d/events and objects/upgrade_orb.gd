extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player2D":
		body.max_depth += 6
		queue_free()
