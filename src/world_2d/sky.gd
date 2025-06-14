extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player2D":
		body.above_water = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player2D":
		body.above_water = false
