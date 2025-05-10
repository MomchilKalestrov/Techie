@tool
extends Node3D;
class_name Wall3D;

const type: String = "Wall";
@export var size: Vector2 = Vector2(1.0, 1.0);
const is_wall: bool = true;

func _ready():
	var wall: StaticBody3D = StaticBody3D.new();
	wall.position.y = 0.25;
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	collision.shape.size = Vector3(size.x - 0.1, 0.5, size.y - 0.1);
	
	var mesh: MeshInstance3D = MeshInstance3D.new();
	mesh.mesh = BoxMesh.new();
	mesh.mesh.size = Vector3(size.x, 0.5, size.y);
	mesh.position.y = 0.25;
	mesh.mesh.material = preload("res://visual/materials/wall/wall.tres");
	
	var roof: MeshInstance3D = MeshInstance3D.new();
	roof.mesh = PrismMesh.new();
	roof.position.y = 0.375;
	if size.x > size.y:
		roof.rotation_degrees.y = 90.0;
		roof.mesh.size = Vector3(size.y, 0.25, size.x);
	else:
		roof.mesh.size = Vector3(size.x, 0.25, size.y);
	roof.mesh.material = preload("res://visual/materials/roof_tiles/roof_tiles.tres");
	
	wall.add_child(collision);
	wall.add_child(roof);
	add_child(wall);
	add_child(mesh);
