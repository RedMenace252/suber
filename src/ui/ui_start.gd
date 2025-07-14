extends CanvasLayer

@onready var start_button = $PanelContainer/VBoxContainer/Start
@onready var exit_button = $PanelContainer/VBoxContainer/Exit
@onready var flashing_logo = $PanelContainer/VBoxContainer/Logo/FlashingLogo

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_start_pressed():
	var main_scene = load("res://src/main/main.tscn")
	get_tree().change_scene_to_packed(main_scene)

func _on_exit_pressed():
	get_tree().quit()
