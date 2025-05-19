extends Panel;
class_name Condition;

var _is_dragging: bool = false;
var _title: Label = Label.new();

signal drag_start(condition: Condition);
signal drag_end(condition: Condition);

var parent_block: ConditionalBlock;
var js_code: String = "";
var title: String:
	get:
		return _title.text;
	set(value):
		_title.text = value;

func _init() -> void:
	var stylebox: StyleBoxFlat = StyleBoxFlat.new();
	stylebox.corner_detail = 1;
	stylebox.set_corner_radius_all(12);
	stylebox.bg_color = Color.MEDIUM_PURPLE;
	add_theme_stylebox_override("panel", stylebox);

func _ready() -> void:
	_title.position = Vector2(12.0, 0.0);
	add_child(_title);
	size = Vector2(24.0 + _title.size.x, 24.0);

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

func _process(_delta: float) -> void:
	if parent_block != null:
		position = parent_block.position + Vector2(parent_block.size.x + 4.0, 4.0);
