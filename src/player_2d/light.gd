extends PointLight2D

func flicker_light_off():
	var tween := create_tween()
	
	# Flicker using self, since you're already the PointLight2D
	tween.tween_property(self, "energy", 0.0, 0.05)
	tween.tween_property(self, "energy", 20.0, 0.05)
	tween.tween_property(self, "energy", 0.0, 0.05)
	tween.tween_property(self, "energy", 20.0, 0.05)
	tween.tween_property(self, "energy", 0.0, 0.1)
	
	# Optional: fade out visibility
	tween.tween_callback(func(): self.visible = false)
