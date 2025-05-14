@tool
@icon("res://prefabs/vector2_input/vector2_input.png")
extends HFlowContainer;
class_name Vector2Input;

var _x_input: SpinBox = SpinBox.new();
var _y_input: SpinBox = SpinBox.new();

@export var value: Vector2:
	get:
		return Vector2(
			_x_input.value,
			_y_input.value
		);
	set(value):
		_x_input.value = value.x;
		_y_input.value = value.y;

@export var max_value: Vector2:
	get:
		return Vector2(
			_x_input.max_value,
			_y_input.max_value
		);
	set(value):
		_x_input.max_value = value.x;
		_y_input.max_value = value.y;


@export var min_value: Vector2:
	get:
		return Vector2(
			_x_input.min_value,
			_y_input.min_value
		);
	set(value):
		_x_input.min_value = value.x;
		_y_input.min_value = value.y;

signal vector_changed(vector: Vector2);

func _ready() -> void:
	alignment = FlowContainer.ALIGNMENT_CENTER;
	
	_x_input.custom_arrow_step = 0.1;
	var x_container: HBoxContainer = HBoxContainer.new();
	var x_label: Label = Label.new();
	x_label.text = "X";
	x_label.add_theme_color_override("font_color", Color.BROWN);
	
	x_container.add_child(x_label);
	x_container.add_child(_x_input);
	add_child(x_container);
	
	_y_input.custom_arrow_step = 0.1;
	var y_container: HBoxContainer = HBoxContainer.new();
	var y_label: Label = Label.new();
	y_label.text = "Y";
	y_label.add_theme_color_override("font_color", Color.WEB_GREEN);
	
	y_container.add_child(y_label);
	y_container.add_child(_y_input);
	add_child(y_container);
	
	_x_input.value_changed.connect(update);
	_y_input.value_changed.connect(update);

func update(_value: float) -> void:
	vector_changed.emit(value);
