extends Node2D

var clean = true

func _ready() -> void:
	SignalBus.switch_artstyle.connect(_switch_artstyle)
	
func _switch_artstyle() -> void:
	clean = !clean
	$Wildlife.visible = !$Wildlife.visible
	if clean:
		$CleanEnvironment.global_position.x = 0
		$Environment.global_position.x = 17280.0
	else:
		$CleanEnvironment.global_position.x = 17280.0
		$Environment.global_position.x = 0
