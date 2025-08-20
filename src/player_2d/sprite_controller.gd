extends Node2D
#i used chatgpt here cry about it

# Dictionary to store sprites by name
var sprites: Dictionary = {}
var current_sprite : AnimatedSprite2D 
var current_animation : String = "default"
var playing : bool = true

func _ready() -> void:
	# Collect sprites and hide them
	for child in get_children():
		if child is Node2D and child.name.ends_with("Sprite"):
			sprites[child.name] = child
			child.visible = false
	
	# Show default sprite
	if "DefaultSprite" in sprites:
		sprites["DefaultSprite"].visible = true
		current_sprite = $DefaultSprite
	else:
		push_error("no default sprite found")
	
	#run default animation
	current_animation = "default"
	
	# Connect to the SignalBus
	if SignalBus.has_signal("switch_artstyle"):
		SignalBus.connect("switch_artstyle", Callable(self, "_on_switch_artstyle"))

func _process(delta: float) -> void:
	if playing:
		current_sprite.play(current_animation)
	else:
		current_sprite.stop()

func switch_sprite(sprite_name: String) -> void:
	# Hide all sprites
	for s in sprites.values():
		s.visible = false
	
	# Show requested sprite if it exists
	if sprite_name in sprites:
		sprites[sprite_name].visible = true
		current_sprite = sprites[sprite_name]
	else:
		push_warning("Sprite '%s' not found." % sprite_name)

func _set_animation(animation_name : String):
	if current_sprite.sprite_frames.has_animation(animation_name):
		current_animation = animation_name
	else:
		push_warning(current_sprite.name + " does not have an animation called " + animation_name)

func _on_switch_artstyle() -> void:
	# Toggle between OldSprite and the current sprite
	if current_sprite.name != "OldSprite" and "OldSprite" in sprites:
		switch_sprite("OldSprite")
	elif "DefaultSprite" in sprites:
		switch_sprite("DefaultSprite")
