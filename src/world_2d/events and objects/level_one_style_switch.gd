extends Node2D

var old : bool = false

func _ready() -> void:
	SignalBus.switch_artstyle.connect(_switch_artstyle)
	
func _switch_artstyle() -> void:
	old = !old
	if !old:
		$Environment.global_position.x = 0
		$OldEnvironment.global_position.x = 17280.0
	else:
		$Environment.global_position.x = 17280.0
		$OldEnvironment.global_position.x = 0
