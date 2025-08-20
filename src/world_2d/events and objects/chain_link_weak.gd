extends RigidBody2D

@export var joint_above : PinJoint2D
@export var joint_below : PinJoint2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player2D" && body.is_dashing:
		joint_above.node_b = NodePath("")
		joint_below.node_a = NodePath("")
		joint_above.get_parent().apply_impulse(Vector2(1000,0))
		joint_below.get_parent().apply_impulse(Vector2(1000,0))
		
