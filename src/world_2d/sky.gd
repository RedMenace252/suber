extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if "above_water" in body:
		body.above_water = true


func _on_body_exited(body: Node2D) -> void:
	if "above_water" in body:
		body.above_water = false
