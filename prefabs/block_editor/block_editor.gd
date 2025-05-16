extends Control;

var _index: int = 0;
var _blocks_data: Array[ CommandBlockData ] = [
	CommandBlockData.new("Move Forwards", Color.ROYAL_BLUE, "await moveForwards();\n"),
	CommandBlockData.new("Move Backwards", Color.ROYAL_BLUE, "await moveBackwards();\n"),
	CommandBlockData.new("Turn Left", Color.LIME_GREEN, "await turnLeft();\n"),
	CommandBlockData.new("Turn Right", Color.LIME_GREEN, "await turnRight();\n"),
	CommandBlockData.new("Interract", Color.INDIAN_RED, "await interract();")
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
	block.js_code = "";
	block.start_block = true;
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
	block.name = "block-" + str(_index);
	block.title = block_data.title;
	block.color = block_data.color;
	block.js_code = block_data.js_code;
	%Nodes.add_child(block);
	_index += 1;

func _drag_block(block: CommandBlock) -> void:
	if block.start_block:
		return;
	for child in %Nodes.get_children():
		if \
			Rect2(child.position, child.size).has_point(block.position) and \
			child.name != block.name:
			child.next_block = block;
			block.previous_block = child;
			return;

func extract_js_code() -> String:
	return %StartBlock.extract_js_code();
