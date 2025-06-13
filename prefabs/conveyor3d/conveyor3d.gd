@tool
@icon("res://prefabs/conveyor3d/conveyor3d.png")
extends Area3D;
class_name Conveyor3D;

const type: String = "Conveyor";

var _movement_direction: Vector3 = Vector3.ZERO;
var speed: float = 1.0;

func _ready() -> void:
	_movement_direction = Vector3.FORWARD.rotated(Vector3.UP, rotation.y);
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	collision.shape.size *= 0.9;
	
	add_child(preload("res://visual/models/conveyor/conveyor.glb").instantiate());
	add_child(collision);

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is not CharacterBody3D:
			body.position += _movement_direction * delta * speed;

func serialize() -> Dictionary:
	return {
		"type": "conveyor",
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
