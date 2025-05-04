@tool

@icon("res://prefabs/button3d/button3d.png")

extends Node3D;

class_name Button3D;

signal button_pressed();
signal button_released();

var _is_pressed: bool = false;
var is_pressed: bool:
	get:
		return _is_pressed;

var _button: MeshInstance3D;

func _ready() -> void:
	var area: Area3D = Area3D.new();
	area.position.y = 0.125;
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	collision.shape.size.y = 0.25;
	
	var base: MeshInstance3D = MeshInstance3D.new();
	base.mesh = BoxMesh.new();
	base.mesh.size.y = 0.125;
	base.position.y = 0.06125;
	
	var button: MeshInstance3D = MeshInstance3D.new();
	button.mesh = BoxMesh.new();
	button.mesh.size = Vector3(0.875, 0.125, 0.875);
	button.mesh.material = preload("res://visual/materials/red_plastic.tres");
	button.position.y = 0.125;

	add_child(area);
	area.add_child(collision);
	add_child(base);
	add_child(button);
	
	_button = button;
	
	area.body_entered.connect(_pressed);
	area.body_exited.connect(_released);

func _process(delta: float) -> void:
	_button.position.y = lerp(_button.position.y, 0.06125 if _is_pressed else 0.125, min(1, 5 * delta));

func _pressed(_body: Node3D) -> void:
	button_pressed.emit();
	_is_pressed = true;

func _released(_body: Node3D) -> void:
	button_released.emit();
	_is_pressed = false;
