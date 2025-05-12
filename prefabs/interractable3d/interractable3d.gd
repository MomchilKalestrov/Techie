@tool
@icon("res://prefabs/interractable3d/interractable3d.png")
extends Area3D;
class_name Interractable3D;

const type: String = "Interractable";

var _collider: CollisionShape3D;

signal interracted();

@export var size: Vector3:
	get:
		if _collider and _collider.shape:
			return _collider.shape.size;
		else:
			return Vector3.ZERO;
	set(value):
		_collider.shape.size = value;

func _ready() -> void:
	_collider = CollisionShape3D.new();
	_collider.shape = BoxShape3D.new();
	add_child(_collider);

func interract() -> void:
	interracted.emit();
