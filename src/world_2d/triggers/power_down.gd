extends Area2D

var triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if not triggered and body.name == "Player2D":
		triggered = true
		SignalBus.submarine_power_off.emit()
		
		await get_tree().create_timer(2.0).timeout
		SignalBus.emit_signal("display_dialogue", "power_down")
		await SignalBus.dialogue_finished
		
		get_tree().root.get_node("Main").toggle_view_mode()
