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
	
	var mesh: MeshInstance3D = MeshInstance3D.new();
	mesh.mesh = BoxMesh.new();
	mesh.mesh.material = preload("res://visual/materials/crate/crate.tres");
	
	add_child(collision);
	add_child(mesh);

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
