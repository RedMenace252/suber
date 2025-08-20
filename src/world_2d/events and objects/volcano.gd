extends Node2D
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player2D":
		body._external_input(Vector2(0,-1200), 0.3)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player2D":
		body._external_input(Vector2(0,1200), 0.5)
