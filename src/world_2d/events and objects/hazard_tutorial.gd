extends Node2D

var triggered = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player2D" && !triggered:
		$TutorialDisplay.play("HazardTutorial")
		triggered = true
