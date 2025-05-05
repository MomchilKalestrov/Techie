@tool

extends Node3D

class_name Wall3D

func _ready():
	var wall: StaticBody3D = StaticBody3D.new();
	wall.position.y = 0.25;
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	collision.shape.size = Vector3(0.9, 0.5, 0.9);
	
	var mesh: MeshInstance3D = MeshInstance3D.new();
	mesh.mesh = BoxMesh.new();
	mesh.mesh.size.y = 0.5;
	mesh.position.y = 0.25;
	
	wall.add_child(collision);
	add_child(wall);
	add_child(mesh);
