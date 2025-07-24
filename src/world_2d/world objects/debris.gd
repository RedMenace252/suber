extends RigidBody2D

func _ready() -> void:
	SignalBus.move_debris.connect(on_move_debris)

func on_move_debris() -> void:
	global_position.x = 100000
