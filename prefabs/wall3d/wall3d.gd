@tool

extends Node3D

class_name Wall3D

func _ready():
	var wall: StaticBody3D = StaticBody3D.new();
	wall.position.y = 0.25;
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	collision.shape.size = Vector3(0.9, 0.5, 0.9);
	
	var house: Node3D = preload("res://visual/models/wall/wall.glb").instantiate();
	
	wall.add_child(collision);
	add_child(wall);
	add_child(house);
