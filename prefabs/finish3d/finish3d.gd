@tool
@icon("res://prefabs/finish3d/finish3d.png")
extends Area3D;
class_name Finish3D;

const type: String = "Finish";

func _ready() -> void:
	var mesh: Node3D = preload("res://visual/models/finish/finish.glb").instantiate();
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	collision.shape.size *= 0.5;
	
	add_child(mesh);
	add_child(collision)
	
	body_entered.connect(_finish);

func _finish(body: Node3D) -> void:
	if body is CharacterBody3D:
		print("FINISH");

func serialize() -> Dictionary:
	return {
		"type": "finish",
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
