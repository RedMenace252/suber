extends CanvasLayer

@onready var continue_button = $PanelContainer/VBoxContainer/Continue
@onready var restart_button = $PanelContainer/VBoxContainer/Restart
@onready var exit_button = $PanelContainer/VBoxContainer/Exit

func _ready():
	visible = false
	
func _unhandled_input(event):
	if event.is_action_pressed("esc"):
		toggle_menu()

func toggle_menu():
	visible = not visible
	get_tree().paused = visible
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_continue_pressed():
	toggle_menu()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().quit()
