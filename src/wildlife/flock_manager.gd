extends Node2D

@export var fish_scene: PackedScene
@export_range(5, 10) var fish_count: int = 7
var fish_list = []
var goal_timer = 0
var goal_cooldown = 5

func _ready():
	for i in fish_count:
		var fish = fish_scene.instantiate()
		add_child(fish)
		
		# Randomize position within screen
		var screen_size = get_viewport_rect().size
		fish.global_position = global_position + Vector2(randf_range(-50,50), randf_range(-50,50))
		fish_list.append(fish)

	# Share reference to all fish
	for fish in fish_list:
		fish.all_fish = fish_list

func _physics_process(delta: float) -> void:
	goal_timer += delta
	
	if goal_timer > goal_cooldown:
		goal_timer = randf() * goal_cooldown
		var goal_direction = randf() * 360
		for fish in fish_list:
			fish.goal_dir = goal_direction
		
