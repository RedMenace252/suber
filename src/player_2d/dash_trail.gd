extends Line2D

@export var lifetime := 1.0
var timer := 0.0

func _ready():
	timer = lifetime
	set_process(true)

func _process(delta):
	timer -= delta
	default_color.a = timer #increase opacity over cooldown (Fade out)
	if timer <= 0:
		queue_free()
