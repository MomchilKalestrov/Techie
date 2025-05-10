@tool
@icon("res://prefabs/blockade3d/blockade3d.png")
extends Node3D;
class_name Blockade3D;

const type: String = "Blockade";
@export var activator: Activator3D;

var _blockade: StaticBody3D;

func _ready() -> void:
	if activator == null:
		push_error("Activator cannot be null");
	
	var base: Node3D = preload("res://visual/models/blockade/base.glb").instantiate();
	
	_blockade = StaticBody3D.new();
	_blockade.position.y = 0.5;
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	
	var bars: Node3D = preload("res://visual/models/blockade/bars.glb").instantiate();
	
	add_child(base);
	_blockade.add_child(collision);
	_blockade.add_child(bars);
	add_child(_blockade);

func _process(delta: float) -> void:
	_blockade.position.y = lerp(_blockade.position.y, -0.5 if activator.is_active() else 0.5, min(1, 5 * delta));
