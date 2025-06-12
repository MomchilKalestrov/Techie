@tool
@icon("res://prefabs/moveable3d/moveable3d.png")
extends RigidBody3D;
class_name Moveable3D;

const type: String = "Moveable";
const save_state: bool = true;

func _ready() -> void:
	lock_rotation = true;
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	
	add_child(collision);
	add_child(preload("res://visual/models/crate/crate.glb").instantiate());

func _physics_process(_delta: float) -> void:
	if linear_velocity.snappedf(0.01) != Vector3.ZERO:
		rotation.y = atan2(linear_velocity.x, linear_velocity.z) - PI / 2;

func serialize() -> Dictionary:
	return {
		"type": "moveable",
		"name": name,
		"position": {
			"x": position.x,
			"y": position.y,
			"z": position.z
		},
		"rotation": {
			"x": rotation_degrees.x,
			"y": rotation_degrees.y,
			"z": rotation_degrees.z
		}
	};
