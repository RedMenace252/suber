extends RigidBody2D

func _ready() -> void:
	SignalBus.move_debris.connect(on_move_debris)

func on_move_debris() -> void:
	apply_impulse(Vector2(100000,0))
	mass = 0.1
