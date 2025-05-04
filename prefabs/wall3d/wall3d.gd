@tool

extends Node3D

class_name Wall3D

func _ready():
	var wall: StaticBody3D = StaticBody3D.new();
	wall.position.y = 0.5;
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	
	wall.add_child(collision);
	add_child(wall);
