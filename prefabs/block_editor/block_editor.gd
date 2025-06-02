extends Control;

var _start_block: CommandBlock;
var _index: int = 0;
var _blocks_data: Array[ CommandBlockData ] = [
	CommandBlockData.new(
		"Move Forwards",
		Color.ROYAL_BLUE,
		"\nawait moveForwards();%0",
		1
	),
	CommandBlockData.new(
		"Move Backwards",
		Color.ROYAL_BLUE,
		"\nawait moveBackwards();%0",
		1
	),
	CommandBlockData.new(
		"Turn Left",
		Color.LIME_GREEN,
		"\nawait turnLeft();%0",
		1
	),
	CommandBlockData.new(
		"Turn Right",
		Color.LIME_GREEN,
		"\nawait turnRight();%0",
		1
	),
	CommandBlockData.new(
		"Interract",
		Color.INDIAN_RED,
		"\nawait interract();%0",
		1
	),
	CommandBlockData.new(
		"Loop",
		Color.REBECCA_PURPLE,
		"while(%c) {%1};%0",
		2,
		"ConditionalBlock"
	)
];

var _conditions_data: Array[ ConditionData ] = [
	ConditionData.new("True", "true"),
	ConditionData.new("False", "false"),
	ConditionData.new("Facing Wall", "await isFacingWall()"),
	ConditionData.new("Not Facing Wall", "!(await isFacingWall())"),
];

func _ready() -> void:
	# add code blocks (move forwards, turn left, interract, while loop and others)
	# to the lists
	for block_data in _blocks_data:
		$NavContainer/FlexBox/OptionButton.add_item(block_data.title);
	$NavContainer/FlexBox/OptionButton.add_separator("Conditions")
	# add conditions for the conditional blocks (if statements, while loops and more)
	for condition_data in _conditions_data:
		$NavContainer/FlexBox/OptionButton.add_item(condition_data.title);
	$NavContainer/FlexBox/OptionButton.selected = 0;
	
	# add the block that the program will start from
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

func _add_block(block_data: CommandBlockData) -> void:
	var block: CommandBlock = Globals.instantiate_class(block_data.block_class);
	block.drag_end.connect(_drag_block);
	block.title = block_data.title;
	block.color = block_data.color;
	block.js_code = block_data.js_code;
	%Nodes.add_child(block);
	block.name = "block-" + str(_index);
	_index += 1;

func _add_condition(condititon_data: ConditionData) -> void:
	var condition: Condition = Condition.new();
	condition.drag_end.connect(_drag_condition);
	condition.js_code = condititon_data.js_code;
	condition.title = condititon_data.title;
	%Nodes.add_child(condition);
	condition.name = "conditional-" + str(_index);
	_index += 1;

func _add(index: int) -> void:
	$NavContainer/FlexBox/OptionButton.selected = 0;
	if index == 0:
		return;
	# subtract 1 because there is a title that counts as an element at index 0
	var item_index = index - 1;
	
	# command block data is added first and then the conditions,
	# so if the user wants to add a condition we need to get
	# the offset of the _condition_data array
	
	if item_index < len(_blocks_data):
		_add_block(_blocks_data[ item_index ]);
	else:
		# add another "- 1" because there is a title
		# that seperates the blocks and conditions and
		# that counts as an element from the list
		_add_condition(_conditions_data[ item_index - 1 - len(_blocks_data) ]);

func _drag_block(dragged_block: CommandBlock) -> void:
	if dragged_block.start_block:
		return;
	
	var nodes: Array[ Node ] = %Nodes.get_children();
	for node in nodes:
		if node.name == dragged_block.name or not node is CommandBlock:
			continue;
		var block: CommandBlock = node;
		for connection in block.connections:
			if connection.can_connect(dragged_block.global_position):
				connection.connect_block(dragged_block);

func _drag_condition(dragged_condition: Condition) -> void:
	var nodes: Array[ Node ] = %Nodes.get_children();
	for node in nodes:
		if not node is ConditionalBlock:
			continue;
		var block: ConditionalBlock = node as ConditionalBlock;
		if block.can_connect(dragged_condition.position):
			block.replace_condition(dragged_condition);

func extract_js_code() -> String:
	return _start_block.extract_js_code();
