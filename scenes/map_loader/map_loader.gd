extends Node3D;

func _ready() -> void:
	load_map();
	Globals.world = self;
	if OS.get_name() == "Web":
		$Floor/Water.material_override = preload("res://visual/materials/water/fallback/water.tres");
		$WorldEnvironment.environment.adjustment_enabled = false;
		$WorldEnvironment.environment.adjustment_brightness = 0.9;

func load_map() -> void:
	_load_world();
	await get_tree().process_frame;

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

func reset() -> void:
	load_map();
