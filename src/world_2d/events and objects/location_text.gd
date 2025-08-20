extends Node2D

var triggered = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player2D" && !triggered:
		$TextFade.play("location_text")
		triggered = true
