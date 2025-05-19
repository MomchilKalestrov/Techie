extends Control;

var _start_block: CommandBlock;
var _index: int = 0;
var _blocks_data: Array[ CommandBlockData ] = [
	CommandBlockData.new(
		"Move Forwards",
		Color.ROYAL_BLUE,
		"%0\nawait moveForwards();",
		1
	),
	CommandBlockData.new(
		"Move Backwards",
		Color.ROYAL_BLUE,
		"%0\nawait moveBackwards();",
		1
	),
	CommandBlockData.new(
		"Turn Left",
		Color.LIME_GREEN,
		"%0\nawait turnLeft();",
		1
	),
	CommandBlockData.new(
		"Turn Right",
		Color.LIME_GREEN,
		"%0\nawait turnRight();",
		1
	),
	CommandBlockData.new(
		"Interract",
		Color.INDIAN_RED,
		"%0\nawait interract();",
		1
	),
];

func _ready() -> void:
	for block_data in _blocks_data:
		$NavContainer/FlexBox/OptionButton.add_item(block_data.title);
	$NavContainer/FlexBox/OptionButton.selected = 0;
	
	var block: CommandBlock = CommandBlock.new();
	block.drag_end.connect(_drag_block);
	block.name = "block-" + str(_index);
	block.title = "Start";
	block.color = Color.DARK_GOLDENROD;
	block.js_code = "%0";
	block.start_block = true;
	_start_block = block;
	%Nodes.add_child(block);

func _move_up() -> void:
	%Nodes.position.y -= 8;

func _move_down() -> void:
	%Nodes.position.y += 8;

func _move_left() -> void:
	%Nodes.position.x -= 8;

func _move_right() -> void:
	%Nodes.position.x += 8;

func _add_block(index: int) -> void:
	$NavContainer/FlexBox/OptionButton.selected = 0;
	if index == 0:
		return;
	var item_index = index - 1;
	
	var block_data: CommandBlockData = _blocks_data[ item_index ];
	var block: CommandBlock = CommandBlock.new();
	block.drag_end.connect(_drag_block);
	block.title = block_data.title;
	block.color = block_data.color;
	block.js_code = block_data.js_code;
	%Nodes.add_child(block);
	block.name = "block-" + str(_index);
	_index += 1;

func _drag_block(dragged_block: CommandBlock) -> void:
	if dragged_block.start_block:
		return;
	   
	var nodes: Array[ Node ] = %Nodes.get_children();
	for node in nodes:
		if node.name == dragged_block.name:
			continue;
		var block: CommandBlock = node;
		for connection in block.connections:
			if connection.can_connect(dragged_block.global_position):
				connection.connect_block(dragged_block);

func extract_js_code() -> String:
	return _start_block.extract_js_code();
