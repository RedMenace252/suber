extends Area2D

var triggered_count = 0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player2D":
		triggered_count += 1
		
		if triggered_count == 1:
			SignalBus.emit_signal("display_dialogue", "entering tunnel 1")
		else:
			SignalBus.emit_signal("display_dialogue", "entering tunnel 2")
