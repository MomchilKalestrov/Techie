@tool
extends Panel;
class_name CommandBlock;

signal drag_start(block: CommandBlock);
signal drag_end(block: CommandBlock);

var _is_dragging: bool = false;
var _title: Label = Label.new();
var _connections: Array[ BlockConnection ];

var connection_count: int = 1;
@export var start_block: bool = false;
var parent_connection: BlockConnection;
var connections: Array[ BlockConnection ]:
	get:
		return _connections;

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
			get_theme_stylebox("panel").bg_color = value;
			
			for connection in connections:
				connection.get_theme_stylebox("panel").bg_color = value;

@export var js_code: String = "";

func _init() -> void:
	var stylebox: StyleBoxFlat = StyleBoxFlat.new();
	stylebox.bg_color = _color;
	stylebox.set_corner_radius_all(4);
	self.add_theme_stylebox_override("panel", stylebox);

func _ready() -> void:
	_title.position = Vector2(4, 4);
	add_child(_title);
	size = Vector2(_title.size.x + 8, 31);
	
	var stylebox: StyleBoxFlat = StyleBoxFlat.new();
	stylebox.bg_color = _color;
	stylebox.corner_radius_bottom_left = 4;
	stylebox.corner_radius_bottom_right = 4;
	
	_connections.resize(connection_count);
	for index in connection_count:
		_connections[ index ] = BlockConnection.new();
		_connections[ index ].z_index = 99;
		_connections[ index ].size = Vector2(16.0, 8.0);
		_connections[ index ].position = Vector2(4 + 20 * index, size.y);
		_connections[ index ].add_theme_stylebox_override("panel", stylebox);
		add_child(_connections[ index ]);
		_connections[ index ].name = "connection-" + str(index);

func _update_connection_heights() -> void:
	for index in range(connection_count):
		var connection = connections[ index ];
		var connection_length = max(connection_count - 1 - index, get_length(index + 1) - 1);
		connection.size.y = connection_length * 32 + (connection_count - index) * BlockConnection.DEFAULT_CONNECTION_HEIGHT;

func _process(_delta: float) -> void:
	_update_connection_heights();
	if not _is_dragging and parent_connection != null:
		global_position = parent_connection.global_position + Vector2(-4, parent_connection.size.y + 1 - BlockConnection.DEFAULT_CONNECTION_HEIGHT)

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
		if parent_connection != null:
			parent_connection.connected_block = null;
			parent_connection = null;

# %<index> - replaces the given index's code

func extract_js_code() -> String:
	var result: String = js_code;
	for index in connection_count:
		var next_block: CommandBlock = connections[ index ].connected_block;
		if result.contains("%" + str(index)):
			var js_snippet = next_block.extract_js_code() if next_block != null else "";
			result = result.replace("%" + str(index), js_snippet);
	return result;

func get_length(start_index: int) -> int:
	var total_length = 1;
	
	if start_index >= connection_count:
		return total_length;
	
	for index in range(start_index, connection_count):
		var connection = connections[ index ];
		if connection.connected_block != null:
			total_length += connection.connected_block.get_length(0);
	
	return total_length;
