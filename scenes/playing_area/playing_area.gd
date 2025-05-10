extends Node3D;

var _node_states: Dictionary[ int, Variant ] = {};

@export var load_editor: bool = true;

func _ready() -> void:
	if not load_editor:
		$SplitContainer.queue_free();
		return;
	Globals.world = self;
	load_map();

func load_map() -> void:
	_load_world();
	await get_tree().process_frame;
	_save_state();

func _half_walls(walls: Array[ Wall3D ]) -> void:
	var _merge_walls = func(wall1: Wall3D, wall2: Wall3D) -> void:
		var wall: Wall3D = Wall3D.new();
		wall.position = (wall1.position + wall2.position) / 2;
		wall.size = wall1.size;
		if wall1.position.x == wall2.position.x:
			wall.size.y *= 2;
		else:
			wall.size.x *= 2;
		
		get_tree().current_scene.add_child(wall);
		
		wall1.queue_free();
		wall2.queue_free();
		
		await get_tree().process_frame;
	
	var counter: int = 0;
	for wall in walls:
		if wall != null:
			counter += 1;
	if counter < 2:
		return;
	
	# why aren't there traditional for loops in gdscript :sob:
	var i: int = 0;
	var j: int = 0;
	while i < len(walls) - 1:
		var wall1 = walls[ i ];
		if wall1 == null:
			i += 1;
			continue;
		
		j = i + 1;
		while j < len(walls):
			var wall2 = walls[ j ];
			if wall2 == null or wall1.size != wall2.size:
				j += 1;
				continue;
			
			if \
				(wall1.position.x == wall2.position.x and \
				abs(wall1.position.z - wall2.position.z) == 1.0) \
			or \
				(wall1.position.z == wall2.position.z and \
				abs(wall1.position.x - wall2.position.x) == 1.0):
				_merge_walls.call(wall1, wall2);
				walls[ i ].free();
				walls[ j ].free();
			
			j += 1;
		i += 1;

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
	
	var wall_nodes: Array[ Wall3D ] = [];
	var blockade_nodes: Array[ Variant ] = [];
	var activators: Array[ Activator3D ] = [];
	
	for node in Globals.map_data:
		match node.type:
			"wall":
				var wall: Wall3D = Wall3D.new();
				set_state.call(wall, node);
				wall.size = Vector2(node.size.x, node.size.y);
				wall_nodes.push_front(wall);
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
			"lever":
				var lever: Lever3D = Lever3D.new();
				set_state.call(lever, node);
				add_child(lever);
				activators.push_front(lever);
	
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
	
	_half_walls(wall_nodes);

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
			elif child is Lever3D and child.is_active():
				child._interracted();
	_save_state();

func _is_withing_rect(box_start: Vector2, box_end: Vector2, point: Vector2) -> bool:
	return box_start.x < point.x and box_end.x > point.x and box_start.y < point.y and box_end.y > point.y;

var _is_dragging: bool = false;
func _input(event: InputEvent) -> void:
	if not load_editor:
		return;
	
	if event is InputEventMouseButton:
		var dragger_position: Vector2 = $SplitContainer/Window/DragRegion.global_position;
		var dragger_size: Vector2 = $SplitContainer/Window/DragRegion.size;
		_is_dragging = _is_withing_rect(dragger_position, dragger_position + dragger_size, event.global_position) and not _is_dragging;
	
	if event is InputEventMouseMotion and _is_dragging:
		$CameraPivot.rotation_degrees.y += event.screen_relative.x;
