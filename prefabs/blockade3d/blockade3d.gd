@tool
@icon("res://prefabs/blockade3d/blockade3d.png")
extends Node3D;
class_name Blockade3D;

const type: String = "Blockade";
var activator: Activator3D = Activator3D.new();

var _blockade: StaticBody3D;

func _ready() -> void:
	# fallback for the map editor
	if activator.name == null:
		activator.name = "null";
	
	# initialize the model
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

# if the activator (lever, button or else) is active, lower the bars
func _process(delta: float) -> void:
	_blockade.position.y = lerp(_blockade.position.y, -0.5 if activator.is_active() else 0.5, min(1, 5 * delta));

func serialize() -> Dictionary:
	return {
		"type": "blockade",
		"name": name,
		"activator": activator.name,
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
