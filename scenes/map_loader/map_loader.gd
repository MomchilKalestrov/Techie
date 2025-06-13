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
			"button", "lever":
				var activator: Activator3D = Globals.instantiate_class(node.type.capitalize() + "3D");
				$Nodes.add_child(activator);
				Globals.set_map_node_state(activator, node);
				activators.push_front(activator);
			"blockade": # ignore blockades untill we have initialized all buttons, that way we can link them together
				blockade_nodes.push_front(node);
			"player":
				var player = preload("res://prefabs/player/player.tscn").instantiate();
				$Nodes.add_child(player);
				Globals.set_map_node_state(player, node);
			_:
				var body = Globals.instantiate_class(node.type.capitalize() + "3D");
				$Nodes.add_child(body);
				Globals.set_map_node_state(body, node);
	
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
