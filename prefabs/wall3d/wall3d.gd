@tool
extends Node3D;
class_name Wall3D;

var _size: Vector2 = Vector2(1.0, 1.0);

const type: String = "Wall";
var size: Vector2:
	get:
		return _size;
	set(value):
		_update_size(value);

const is_wall: bool = true;

var _collision: CollisionShape3D = CollisionShape3D.new();
var _mesh: MeshInstance3D = MeshInstance3D.new();
var _roof: MeshInstance3D = MeshInstance3D.new();

func _init():
	var wall: StaticBody3D = StaticBody3D.new();
	wall.position.y = 0.25;
	
	_collision.shape = BoxShape3D.new();
	
	_mesh.mesh = BoxMesh.new();
	_mesh.position.y = 0.25;
	_mesh.mesh.material = preload("res://visual/materials/wall/wall.tres");
	
	_roof.mesh = PrismMesh.new();
	_roof.position.y = 0.375;
	_roof.mesh.material = preload("res://visual/materials/roof_tiles/roof_tiles.tres");
	
	wall.add_child(_collision);
	wall.add_child(_roof);
	add_child(wall);
	add_child(_mesh);
	
	_update_size(size);

func _update_size(new_size: Vector2) -> void:
	_size = new_size;
	_collision.shape.size = Vector3(new_size.x - 0.1, 0.5, new_size.y - 0.1);
	
	_mesh.mesh.size = Vector3(new_size.x, 0.5, new_size.y);
	
	if new_size.x > new_size.y:
		_roof.rotation_degrees.y = 90.0;
		_roof.mesh.size = Vector3(new_size.y, 0.25, new_size.x);
	else:
		_roof.rotation_degrees.y = 0.0;
		_roof.mesh.size = Vector3(new_size.x, 0.25, new_size.y);

func serialize() -> Dictionary:
	return {
		"type": "wall",
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
		},
		"size": {
			"x": size.x,
			"y": size.y
		}
	};
