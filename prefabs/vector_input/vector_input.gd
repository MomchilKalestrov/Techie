@tool
@icon("res://prefabs/vector_input/vector_input.png")
extends HFlowContainer;
class_name VectorInput;

var _x_input: SpinBox = SpinBox.new();
var _y_input: SpinBox = SpinBox.new();
var _z_input: SpinBox = SpinBox.new();

@export var value: Vector3:
	get:
		return Vector3(
			_x_input.value,
			_y_input.value,
			_z_input.value
		);
	set(value):
		_x_input.value = value.x;
		_y_input.value = value.y;
		_z_input.value = value.z;

@export var max_value: Vector3:
	get:
		return Vector3(
			_x_input.max_value,
			_y_input.max_value,
			_z_input.max_value
		);
	set(value):
		_x_input.max_value = value.x;
		_y_input.max_value = value.y;
		_z_input.max_value = value.z;


@export var min_value: Vector3:
	get:
		return Vector3(
			_x_input.min_value,
			_y_input.min_value,
			_z_input.min_value
		);
	set(value):
		_x_input.min_value = value.x;
		_y_input.min_value = value.y;
		_z_input.min_value = value.z;

signal vector_changed(vector: Vector3);

func _ready() -> void:
	alignment = FlowContainer.ALIGNMENT_CENTER;
	
	var x_container: HBoxContainer = HBoxContainer.new();
	var x_label: Label = Label.new();
	x_label.text = "X";
	x_label.add_theme_color_override("font_color", Color.BROWN);
	
	x_container.add_child(x_label);
	x_container.add_child(_x_input);
	add_child(x_container);
	
	var y_container: HBoxContainer = HBoxContainer.new();
	var y_label: Label = Label.new();
	y_label.text = "Y";
	y_label.add_theme_color_override("font_color", Color.WEB_GREEN);
	
	y_container.add_child(y_label);
	y_container.add_child(_y_input);
	add_child(y_container);
	
	var z_container: HBoxContainer = HBoxContainer.new();
	var z_label: Label = Label.new();
	z_label.text = "Z";
	z_label.add_theme_color_override("font_color", Color.ROYAL_BLUE);
	
	z_container.add_child(z_label);
	z_container.add_child(_z_input);
	add_child(z_container);
	
	_x_input.value_changed.connect(update);
	_y_input.value_changed.connect(update);
	_z_input.value_changed.connect(update);

func update(_value: float) -> void:
	vector_changed.emit(value);
