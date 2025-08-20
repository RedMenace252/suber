extends Sprite2D

var pirate_mode_ready = false

func _on_treasure_chest_treasure_chest() -> void:
	pirate_mode_ready = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player2D" && pirate_mode_ready:
		$Label.visible = true
		body.pirate_mode_ready = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player2D" && pirate_mode_ready:
		$Label.visible = false
		body.pirate_mode_ready = false
