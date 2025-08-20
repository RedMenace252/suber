extends Node2D


func _on_ball_drop_zone_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		SignalBus.emit_signal("shake_camera")
		queue_free()
