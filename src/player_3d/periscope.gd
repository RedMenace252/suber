extends StaticBody3D

var enabled = false

func _ready():
	SignalBus.sonar_enabled.connect(_enable_periscope)
	
func _enable_periscope():
	enabled = true
	print("lebron")
	
func on_button_pressed():
	if enabled:
		SignalBus.emit_signal("toggle_view")
