extends Camera2D


@onready var screen_size := get_viewport_rect().size
var cur_screen := Vector2( 0, 0 )

var shake_timer: float = 0.0
var shake_strength: float = 10.0
var is_shaking: bool = false

var large_areas = [
	{
		"bounds": [Vector2(4, 0), Vector2(5, 1)],
		"center": Vector2(4.5, 0.5),
		"zoom": 0.5
	},
	{
		"bounds": [Vector2(4, 6), Vector2(6, 8)],
		"center": Vector2(5, 7),
		"zoom": .33333
	}
]
var in_large_area = false
var cur_large_area = null

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
		global_position = found_large_area["center"] * screen_size + screen_size * 0.5
		in_large_area = true

	# Leaving large area
	elif not found_large_area and cur_large_area != null:
		cur_large_area = null
		zoom = Vector2(1, 1)
		global_position = cur_screen * screen_size + screen_size * 0.5
		in_large_area = false

	# Not changing large area state
	elif not in_large_area:
		global_position = cur_screen * screen_size + screen_size * 0.5

	get_parent().set_current_screen(cur_screen)

	if cur_screen.y > 1:
		$DarkTint.visible = true
		$DarkTint.color = Color(0, 0, .2,clamp(.3 + .1 * cur_screen.y, 0.3, 0.8))
	else:
		$DarkTint.visible = false

		
	
func on_shake_camera() -> void:
	is_shaking = true
	shake_timer = 1
