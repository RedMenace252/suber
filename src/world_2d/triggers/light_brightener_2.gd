extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player2D":
		var light = body.get_node("Light")
		light.energy = 20
