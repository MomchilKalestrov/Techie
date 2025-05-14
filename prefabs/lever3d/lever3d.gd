@tool
@icon("res://prefabs/lever3d/lever3d.png")
extends Activator3D;
class_name Lever3D;

const type: String = "Lever";

var _is_powered_on: bool = false;
var _lever: Node3D;
const _lever_tilt: float = 30.0;

func _ready() -> void:
	var base: Node3D = preload("res://visual/models/lever/base.glb").instantiate();
	_lever = preload("res://visual/models/lever/handle.glb").instantiate();
	_lever.rotation_degrees.x = _lever_tilt;
	
	var interractable: Interractable3D = Interractable3D.new();
	interractable.interracted.connect(_interracted);
	
	add_child(interractable);
	add_child(base);
	add_child(_lever);

func _interracted() -> void:
	_is_powered_on = not _is_powered_on;
	if _is_powered_on:
		active.emit();
	else:
		inactive.emit();

func _physics_process(delta: float) -> void:
	_lever.rotation_degrees.x = lerpf(_lever.rotation_degrees.x, -_lever_tilt if _is_powered_on else _lever_tilt, min(1, delta * 10));

func is_active() -> bool:
	return _is_powered_on;

func serialize() -> Dictionary:
	return {
		"type": "lever",
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
