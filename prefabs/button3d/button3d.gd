@tool
@icon("res://prefabs/button3d/button3d.png")
extends Activator3D;
class_name Button3D;

const type: String = "Button";

var _is_pressed: bool = false;
var _button: Node3D;

func is_active() -> bool:
	return _is_pressed;

func _ready() -> void:
	var area: Area3D = Area3D.new();
	area.position.y = 0.125;
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	collision.shape.size = Vector3(0.9, 0.25, 0.9);
	
	var base: Node3D = preload("res://visual/models/button/base.glb").instantiate();
	
	_button = preload("res://visual/models/button/press.glb").instantiate();

	add_child(area);
	area.add_child(collision);
	add_child(base);
	add_child(_button);
	
	area.body_entered.connect(_pressed);
	area.body_exited.connect(_released);

func _process(delta: float) -> void:
	_button.position.y = lerp(_button.position.y, -0.125 if _is_pressed else 0.0, min(1, 5 * delta));

func _pressed(_body: Node3D) -> void:
	active.emit();
	_is_pressed = true;

func _released(_body: Node3D) -> void:
	inactive.emit();
	_is_pressed = false;

func serialize() -> Dictionary:
	return {
		"type": "button",
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
