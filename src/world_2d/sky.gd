extends Area2D

func _on_body_exited(body: Node2D) -> void:
	if "above_water" in body:
		body.above_water = false
		if body.name == "Player2D":
			print("exited")

func _on_body_entered(body: Node2D) -> void:
	if "above_water" in body:
		body.above_water = true
		if body.name == "Player2D":
			print("entered")
