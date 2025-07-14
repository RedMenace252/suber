extends StaticBody3D

var pressed = false

func on_button_pressed():
	if not pressed:
		pressed = true
		var mat = $ButtonPresser.get_active_material(0)
		if mat is StandardMaterial3D:
			mat.albedo_color = Color.GREEN
			
		SignalBus.emit_signal("sonar_enabled")
		SignalBus.emit_signal("display_dialogue", "view_switch_tutorial")
