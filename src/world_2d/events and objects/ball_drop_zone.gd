extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		SignalBus.shake_camera.emit()
		SignalBus.move_debris.emit()
