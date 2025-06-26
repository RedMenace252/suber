extends AnimationPlayer

func _ready() -> void:
	SignalBus.fade_in.connect(fade_in)
	SignalBus.fade_out.connect(fade_out)

func fade_in():
	play("fade_in")
	
func fade_out():
	play("fade_out")
