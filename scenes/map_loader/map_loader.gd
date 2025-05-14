extends Node3D;

var _node_states: Dictionary[ int, Variant ] = {};

func _ready() -> void:
	load_map();
	Globals.world = self;

func load_map() -> void:
	_load_world();
	await get_tree().process_frame;
	_save_state();

func _load_world() -> void:
	for child in $Nodes.get_children():
		child.queue_free();
	await get_tree().process_frame;
	
	var blockade_nodes: Array[ Variant ] = [];
	var activators: Array[ Activator3D ] = [];
	
	for node in Globals.map_data:
		match node.type:
			"wall":
				var wall: Wall3D = Wall3D.new();
				$Nodes.add_child(wall);
				Globals.set_map_node_state(wall, node);
				wall.size = Vector2(node.size.x, node.size.y);
			"button":
				var button: Button3D = Button3D.new();
				$Nodes.add_child(button);
				Globals.set_map_node_state(button, node);
				activators.push_front(button);
			"blockade": # ignore blockades untill we have initialized all buttons, that way we can link them together
				blockade_nodes.push_front(node);
			"player":
				var player = preload("res://prefabs/player/player.tscn").instantiate();
				$Nodes.add_child(player);
				Globals.set_map_node_state(player, node);
				player.target_position = Vector3(
					node.position.x,
					node.position.y,
					node.position.z
				);
				player.target_rotation = node.rotation.y;
			"lever":
				var lever: Lever3D = Lever3D.new();
				$Nodes.add_child(lever);
				Globals.set_map_node_state(lever, node);
				activators.push_front(lever);
			"finish":
				var finish: Finish3D = Finish3D.new();
				$Nodes.add_child(finish);
				Globals.set_map_node_state(finish, node);
			"moveable":
				var moveable: Moveable3D = Moveable3D.new();
				$Nodes.add_child(moveable);
				Globals.set_map_node_state(moveable, node);
	
	# wait for the buttons to be added to the tree
	await get_tree().process_frame;
	# initialize the blockades after all the buttons have been added
	for blockade_node in blockade_nodes:
		var blockade = Blockade3D.new();
		Globals.set_map_node_state(blockade, blockade_node);
		# find this blockade's activator
		for activator in activators:
			if activator.name == blockade_node.activator:
				blockade.activator = activator;
		
		$Nodes.add_child(blockade);

func _save_state() -> void:
	_node_states = {};
	for child_index in $Nodes.get_child_count():
		var child: Node = $Nodes.get_child(child_index);
		if "save_state" in child:
			_node_states[ child_index ] = child.duplicate();

func reset() -> void:
	for child_state in _node_states.values():
		for child in $Nodes.get_children():
			if child_state.name == child.name:
				child.queue_free();
				await get_tree().process_frame;
				add_child(child_state);
			elif child is Lever3D and child.is_active():
				child._interracted(); # disable the activated levers
	_save_state();
