extends Camera2D


@onready var screen_size := get_viewport_rect().size
var cur_screen := Vector2( 0, 0 )

var shake_timer: float = 0.0
var shake_strength: float = 10.0
var is_shaking: bool = false

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

func _update_screen( new_screen : Vector2 ):
	cur_screen = new_screen
	global_position = cur_screen * screen_size + screen_size * 0.5
	get_parent().set_current_screen(cur_screen)
	
func on_shake_camera() -> void:
	is_shaking = true
	shake_timer = 1
