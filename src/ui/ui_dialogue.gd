extends CanvasLayer

@export var scene_text_file: Resource

var scene_text := {}
var selected_text := []
var in_progress = false

@onready var text_label = $Panel/Label
@onready var next_button = $Panel/NextButton

func _ready():
	visible = false
	scene_text = load_scene_text()
	SignalBus.display_dialogue.connect(on_display_dialogue)
	next_button.pressed.connect(on_next_button_pressed)

func load_scene_text():
	var scene_text_path = scene_text_file.resource_path
	if FileAccess.file_exists(scene_text_path):
		var file = FileAccess.open(scene_text_path, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())

func show_text():
	text_label.text =  selected_text.pop_front()
	
func next_line():
	if selected_text.size() > 0:
		show_text()
	else:
		finish()
		
func finish():
	text_label.text = ""
	visible = false
	in_progress = false
	get_tree().paused = false

func on_display_dialogue(text_key):
	if in_progress:
		next_line()
	else:
		get_tree().paused = true
		visible = true
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		show_text() 
		next_button.grab_focus()
		
func on_next_button_pressed():
	if in_progress:
		next_line()
