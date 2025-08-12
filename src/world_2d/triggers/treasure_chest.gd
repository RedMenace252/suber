extends Node2D

var triggered = false
signal treasure_chest

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player2D" && !triggered:
		triggered = true
		emit_signal("treasure_chest")
		$AnimatedSprite2D.play("collect")
		$AnimationPlayer.play("collect")
		await $AnimationPlayer.animation_finished
		queue_free()
		
