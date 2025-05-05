extends Node3D;

var _node_states: Dictionary[ int, Node ] = {};

func _ready() -> void:
	Globals.world = self;
	_load_world();
	await get_tree().process_frame;
	_save_state();
	print($HSplitContainer.visible);

func _load_world() -> void:
	var set_state = func(node: Node3D, state: Variant) -> void:
		node.position = Vector3(
			state.position.x,
			state.position.y,
			state.position.z
		);
		node.rotation_degrees = Vector3(
			state.rotation.x,
			state.rotation.y,
			state.rotation.z
		);
		node.name = state.name;
	
	var blockade_nodes: Array[ Variant ] = [];
	var activators: Array[ Button3D ] = [];
	
	for node in Globals.map_data:
		match node.type:
			"wall":
				var wall: Wall3D = Wall3D.new();
				set_state.call(wall, node);
				add_child(wall);
			"button":
				var button: Button3D = Button3D.new();
				set_state.call(button, node);
				add_child(button);
				activators.push_front(button);
			"blockade": # ignore blockades untill we have initialized all buttons, that way we can link them together
				blockade_nodes.push_front(node);
			"player":
				var player = preload("res://prefabs/player/player.tscn").instantiate();
				set_state.call(player, node);
				player.target_position = Vector3(
					node.position.x,
					node.position.y,
					node.position.z
				);
				add_child(player);
	
	# wait for the buttons to be added to the tree
	await get_tree().process_frame;
	# initialize the blockades after all the buttons have been added
	for blockade_node in blockade_nodes:
		var blockade = Blockade3D.new();
		set_state.call(blockade, blockade_node);
		# find this blockade's activator
		for activator in activators:
			if activator.name == blockade_node.activator:
				blockade.activator = activator;
		
		add_child(blockade);

func _save_state() -> void:
	_node_states = {};
	for child_index in get_child_count():
		var child: Node = get_child(child_index);
		if "save_state" in child:
			_node_states[ child_index ] = child.duplicate();


func reset() -> void:
	for child_state in _node_states.values():
		for child in get_children():
			if child_state.name == child.name:
				child.queue_free();
				await get_tree().process_frame;
				add_child(child_state);
				
	_save_state();
