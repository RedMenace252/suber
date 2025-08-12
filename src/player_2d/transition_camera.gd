extends Camera2D


@onready var screen_size := get_viewport_rect().size
var cur_screen := Vector2( 0, 0 )

var shake_timer: float = 0.0
var shake_strength: float = 10.0
var is_shaking: bool = false

@onready var large_areas = LargeAreas.get_large_areas()
var in_large_area = false
var cur_large_area = null
var scrolling_center = false
var center_range = [Vector2(0,0), Vector2(0,0)]

func _ready():
	set_as_top_level( true )
	global_position = get_parent().global_position
	_update_screen( cur_screen )
	
	SignalBus.shake_camera.connect(on_shake_camera)
	
func _process(delta: float) -> void:
	if is_shaking:
		shake_timer -= delta
		if shake_timer > 0:
			offset = Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength)
			)
		else:
			offset = Vector2.ZERO
			is_shaking = false

func _physics_process(_delta):
	var parent_screen : Vector2 = ( get_parent().global_position / screen_size ).floor()
	if not parent_screen.is_equal_approx( cur_screen ):
		_update_screen( parent_screen )
	
	if scrolling_center:
		var player_position = get_parent().global_position
		global_position = Vector2(
			clamp(player_position.x, center_range[0].x, center_range[1].x),
			clamp(player_position.y, center_range[0].y, center_range[1].y)
		)
		
		

func _update_screen(new_screen: Vector2):
	cur_screen = new_screen

	# Check if current room is inside a large area
	var found_large_area = null
	for area in large_areas:
		var a = area["bounds"][0]
		var b = area["bounds"][1]
		var x_range = [min(a.x, b.x), max(a.x, b.x)]
		var y_range = [min(a.y, b.y), max(a.y, b.y)]

		if new_screen.x >= x_range[0] and new_screen.x <= x_range[1] and \
		   new_screen.y >= y_range[0] and new_screen.y <= y_range[1]:
			found_large_area = area
			break

	# Entering a large area
	if found_large_area and cur_large_area != found_large_area:
		cur_large_area = found_large_area
		zoom = Vector2(found_large_area["zoom"], found_large_area["zoom"])
		
		var center = found_large_area["center"]
		if typeof(center) == TYPE_ARRAY and center.size() == 2:
			scrolling_center = true
			center_range = [center[0] * screen_size, center[1] * screen_size]
		else:
			global_position = found_large_area["center"] * screen_size + screen_size * 0.5
		
		in_large_area = true

	# Leaving large area
	elif not found_large_area and cur_large_area != null:
		cur_large_area = null
		zoom = Vector2(1, 1)
		global_position = cur_screen * screen_size + screen_size * 0.5
		in_large_area = false
		scrolling_center = false

	# Not changing large area state
	elif not in_large_area:
		global_position = cur_screen * screen_size + screen_size * 0.5

	get_parent().set_current_screen(cur_screen)
	
	print(cur_large_area)

	
	
func on_shake_camera() -> void:
	is_shaking = true
	shake_timer = 1
