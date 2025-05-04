@tool

@icon("res://prefabs/blockade3d/blockade3d.png")

extends Node3D

class_name Blockade3D

@export var activator: Button3D;
var _blockade: StaticBody3D;

func _ready() -> void:
	if activator == null:
		push_error("Activator cannot be null");
	
	var base: MeshInstance3D = MeshInstance3D.new();
	base.mesh = BoxMesh.new();
	base.mesh.size.y = 0.125;
	base.position.y = 0.06125;
	
	_blockade = StaticBody3D.new();
	_blockade.position.y = 0.5;
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	
	var blockade_mesh: MeshInstance3D = MeshInstance3D.new();
	blockade_mesh.mesh = BoxMesh.new();
	blockade_mesh.mesh.size = Vector3(0.875, 1.0, 0.875);
	
	add_child(base);
	_blockade.add_child(collision);
	_blockade.add_child(blockade_mesh);
	add_child(_blockade);

func _process(delta: float) -> void:
	_blockade.position.y = lerp(_blockade.position.y, -0.5 if activator.is_pressed else 0.5, min(1, 5 * delta));
