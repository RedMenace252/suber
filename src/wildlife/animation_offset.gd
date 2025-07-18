extends AnimatedSprite2D  # Or AnimatedSprite for Godot 3.x

func _ready():
	# Start playing the animation
	play()
	
	# Apply a random time offset
	# animation = current animation name
	var random_progress = randf_range(0.0, 1.0)
	set_frame_and_progress(0, random_progress)
