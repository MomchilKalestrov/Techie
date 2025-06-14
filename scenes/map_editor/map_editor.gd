extends Node3D;

@onready var _list: ItemList = $Container/Divider/NodeListPanel/FlexBox/NodesList;
var _nodes: Dictionary[ String, Node3D ] = {};
var _current_chosen_node: Node3D = null;
const _node_types: Array[ String ] = [
	"Blockade",
	"Button",
	"Finish",
	"Lever",
	"Moveable",
	"Player",
	"Wall",
	"Conveyor"
];

const _scene_types: Dictionary[ String, PackedScene ] = {
	"Player": preload("res://prefabs/player/player.tscn")
};

func _ready() -> void:
	for node_type in _node_types:
		%Type.add_item(node_type);

func _update_properties_panel(node: Node3D) -> void:
	%Name.text = node.name;
	%Position.value = node.position;
	%Rotation.value = node.rotation_degrees;
	%Type.selected = _node_types.find(node.type);
	
	var data_containers: VBoxContainer = $Container/Divider/NodeParametersPanel/ScrollBox/FlexBox;
	for data_container in data_containers.get_children():
		data_container.visible = false;
	data_containers.get_node("BasicDataContainer").visible = true;
	
	var node_data_container = Globals.try_get_node(data_containers, node.type + "DataContainer");
	if node_data_container != null:
		node_data_container.visible = true;
	match node.type:
		"Blockade":
			var activator: LineEdit = data_containers.get_node("BlockadeDataContainer/Activator");
			activator.text = _current_chosen_node.activator.name;
		"Wall":
			var size: Vector2Input = data_containers.get_node("WallDataContainer/Size");
			size.value = _current_chosen_node.size;

func _select_node(index: int) -> void:
	await get_tree().process_frame;
	_current_chosen_node = _nodes[ _list.get_item_text(index) ];
	$Container/Divider/NodeParametersPanel.visible = true;
	$Selector.visible = true;
	$Selector.global_position = _current_chosen_node.global_position;
	_update_properties_panel(_current_chosen_node);

func _generate_random_id() -> String:
	var random_id: int = randi() % 9999;
	var string_id: String = str(random_id).pad_zeros(4);
	return string_id;

func _refresh_list() -> void:
	await get_tree().process_frame;
	_nodes = {};
	_list.clear();
	for child in $NodeContainer.get_children():
		_nodes[ child.name ] = child;
		_list.add_item(child.name);

func _create_node() -> void:
	var node: Wall3D = Wall3D.new();
	$NodeContainer.add_child(node);
	node.name = "node-" + _generate_random_id();
	_refresh_list();
	_current_chosen_node = node;
	_select_node($NodeContainer.get_child_count() - 1);

func _update_name(node_name: String) -> void:
	_current_chosen_node.name = node_name;
	_refresh_list();

func _update_node_position(vector: Vector3) -> void:
	_current_chosen_node.position = vector;
	$Selector.global_position = _current_chosen_node.global_position;

func _update_node_rotation(vector: Vector3) -> void:
	_current_chosen_node.global_rotation_degrees = vector;

func _update_type(index: int) -> void:
	# save the current base state
	var node_name: String = String(_current_chosen_node.name);
	var node_position: Vector3 = _current_chosen_node.position;
	var node_rotation_degrees: Vector3 = _current_chosen_node.rotation_degrees;
	
	var type: String = _node_types[ index ];
	var new_node: Node3D;
	if type in _scene_types:
		new_node = _scene_types[ type ].instantiate();
	else:
		new_node = Globals.instantiate_class(type + "3D");
	
	_current_chosen_node.queue_free();
	$NodeContainer.add_child(new_node);
	_current_chosen_node = new_node;
	
	new_node.name = node_name;
	new_node.position = node_position;
	new_node.rotation_degrees = node_rotation_degrees;
	if new_node is RigidBody3D:
		new_node.freeze = true;
	new_node.set_process(false);
	new_node.set_process_internal(false);
	new_node.set_physics_process(false);
	new_node.set_physics_process_internal(false);
	
	_refresh_list();
	_update_properties_panel(new_node);

func _update_activator_name(node_name: String) -> void:
	var blockade: Blockade3D = _current_chosen_node as Blockade3D;
	blockade.activator.name = node_name;

func _update_size(size: Vector2) -> void:
	var wall: Wall3D = _current_chosen_node as Wall3D;
	wall.size = size;

func _prompt_back() -> void:
	$ConfirmationDialog.confirmed.connect(_confirm_back);
	$ConfirmationDialog.show();

func _confirm_back() -> void:
	$ConfirmationDialog.confirmed.disconnect(_confirm_back);
	get_tree().change_scene_to_file("res://scenes/home_scene/home_scene.tscn");

func _open_save_dialog() -> void:
	$SaveFileDialog.show();

func _save(path: String) -> void:
	var map_data: Array[ Dictionary ] = [];
	
	for child in $NodeContainer.get_children():
		map_data.push_front(child.serialize());
	
	var map_file: FileAccess = FileAccess.open(path, FileAccess.WRITE);
	map_file.store_string(JSON.stringify(map_data, "\t"));

func _is_withing_rect(box_start: Vector2, box_end: Vector2, point: Vector2) -> bool:
	return box_start.x < point.x and box_end.x > point.x and box_start.y < point.y and box_end.y > point.y;

func _prompt_open_map_load() -> void:
	$ConfirmationDialog.confirmed.connect(_confirm_open_map_load);
	$ConfirmationDialog.show();

func _confirm_open_map_load() -> void:
	$ConfirmationDialog.confirmed.disconnect(_confirm_open_map_load);
	$OpenFileDialog.show();

func _load_map(path: String) -> void:
	var map_file: FileAccess = FileAccess.open(path, FileAccess.READ);
	var map_data: Array = JSON.parse_string(map_file.get_as_text());
	
	for child in $NodeContainer.get_children():
		child.queue_free();
	await get_tree().process_frame;
	
	for node_data in map_data:
		var type = node_data.type.capitalize();
		var new_node: Node3D;
		if type in _scene_types:
			new_node = _scene_types[ type ].instantiate();
		else:
			new_node = Globals.instantiate_class(type + "3D");
		$NodeContainer.add_child(new_node);
		
		Globals.set_map_node_state(new_node, node_data);
		match type:
			"Blockade":
				new_node.activator.name = node_data.activator;
		
		if new_node is RigidBody3D:
			new_node.freeze = true;
		new_node.set_process(false);
		new_node.set_process_internal(false);
		new_node.set_physics_process(false);
		new_node.set_physics_process_internal(false);
		
	_refresh_list();

func _delete_node() -> void:
	if _current_chosen_node == null:
		return;
	_current_chosen_node.queue_free();
	$Container/Divider/NodeParametersPanel.visible = false;
	$Selector.visible = false;
	_refresh_list();

var _is_dragging: bool = false;
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not _is_dragging:
			_select_node_by_mouse(Vector2i(event.global_position));
		
		var dragger_position: Vector2 = $Container/Window/DragRegion.global_position;
		var dragger_size: Vector2 = $Container/Window/DragRegion.size;
		_is_dragging = _is_withing_rect(dragger_position, dragger_position + dragger_size, event.global_position) and not _is_dragging;
		
	
	if event is InputEventMouseMotion and _is_dragging:
		$MapLoader/CameraPivot.rotation_degrees.y += event.screen_relative.x;

func _select_node_by_mouse(click_position: Vector2i) -> void:
	var camera: Camera3D = $MapLoader/CameraPivot/Camera
	
	var viewport_rect = get_viewport().get_visible_rect()
	var viewport_position = Vector2(
		click_position.x - viewport_rect.position.x, 
		click_position.y - viewport_rect.position.y
	)
	
	var origin = camera.project_ray_origin(viewport_position)
	var direction = camera.project_ray_normal(viewport_position)
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * 50)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is Node3D:
		var node = result.collider
		var parent_found = false
		for child in $NodeContainer.get_children():
			if child == node or node.is_ancestor_of(child) or child.is_ancestor_of(node):
				# Select this node in the list
				for i in range(_list.item_count):
					if _list.get_item_text(i) == child.name:
						_list.select(i)
						_select_node(i)
						parent_found = true
						break
			if parent_found:
				break;
