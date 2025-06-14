extends Node3D;

const _scenePrefabs: Dictionary[ String, PackedScene ] = {
	"player": preload("res://prefabs/player/player.tscn")
};

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
				Globals.set_map_node_state(activator, node);
				activators.push_front(activator);
				$Nodes.add_child(activator);
			"blockade": # ignore blockades untill we have initialized all buttons, that way we can link them together
				blockade_nodes.push_front(node);
			_:
				var body: Node3D = _scenePrefabs[ node.type ].instantiate() if node.type in _scenePrefabs else Globals.instantiate_class(node.type.capitalize() + "3D");
				Globals.set_map_node_state(body, node);
				$Nodes.add_child(body);
	
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
