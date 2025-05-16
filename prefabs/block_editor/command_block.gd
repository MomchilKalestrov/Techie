@tool
extends Panel;
class_name CommandBlock;

signal drag_start(block: CommandBlock);
signal drag_end(block: CommandBlock);

var _is_dragging: bool = false;
var _title: Label = Label.new();
var _next_block: CommandBlock;

@export var start_block: bool = false;
# this works just like a double linked list lmao
var previous_block: CommandBlock;
var next_block: CommandBlock:
	get:
		return _next_block;
	set(value):
		if value != null:
			value.position = position + Vector2(0.0, size.y + 1);
			value.next_block = _next_block;
			value.previous_block = self;
		_next_block = value;

@export var title: String:
	get:
		return _title.text;
	set(value):
		if not start_block:
			_title.text = value;

var _color: Color = Color(1, 1, 1, 1);
@export var color: Color:
	get:
		return get_theme_stylebox("panel").bg_color;
	set(value):
		if not start_block:
			_color = value;
			get_theme_stylebox("panel").bg_color = Color(value, 0.5);

@export var js_code: String = "";

func _init() -> void:
	var stylebox: StyleBoxFlat = StyleBoxFlat.new();
	stylebox.bg_color = _color;
	stylebox.set_corner_radius_all(4);
	self.add_theme_stylebox_override("panel", stylebox);

func _ready() -> void:
	size = Vector2(len(_title.text) * 12, 31);
	_title.position = Vector2(4, 4);
	add_child(_title);

func _process(_delta: float) -> void:
	if not _is_dragging and previous_block != null:
		position = previous_block.position + Vector2(0, previous_block.size.y + 1);

func _is_within_self(pos: Vector2) -> bool:
	return \
		global_position.x < pos.x and \
		global_position.y < pos.y and \
		pos.x < (global_position + size).x and\
		pos.y < (global_position + size).y;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not _is_within_self(event.global_position):
			return;
		if Input.is_action_just_pressed("left_mouse"):
			drag_start.emit(self);
		elif Input.is_action_just_released("left_mouse") and _is_dragging:
			drag_end.emit(self);
		_is_dragging = Input.is_action_pressed("left_mouse");
	
	if event is InputEventMouseMotion and _is_dragging:
		position += event.screen_relative;
		if previous_block != null:
			previous_block.next_block = null;
			previous_block = null;

func extract_js_code() -> String:
	return js_code + (next_block.extract_js_code() if next_block != null else "");
