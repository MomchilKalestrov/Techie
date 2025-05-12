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
	"Wall"
];

func _ready() -> void:
	for node_type in _node_types:
		%Type.add_item(node_type);

func _update_properties_panel(node: Node3D) -> void:
	%Name.text = node.name;
	%Position.value = node.position;
	%Rotation.value = node.rotation;
	%Type.selected = _node_types.find(node.type);
	
	for data_container in $Container/Divider/NodeParametersPanel/ScrollBox/FlexBox.get_children():
		data_container.visible = false;
	$Container/Divider/NodeParametersPanel/ScrollBox/FlexBox/BasicDataContainer.visible = true;
	
	match node.type:
		"Blockade":
			$Container/Divider/NodeParametersPanel/ScrollBox/FlexBox/BlockadeDataContainer.visible = true;

func _select_node(index: int) -> void:
	await get_tree().process_frame;
	_current_chosen_node = _nodes[ _list.get_item_text(index) ];
	$Container/Divider/NodeParametersPanel.visible = true;
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

func _update_node_rotation(vector: Vector3) -> void:
	_current_chosen_node.global_rotation_degrees = vector;

func _update_type(index: int) -> void:
	# save the current base state
	var node_name: String = String(_current_chosen_node.name);
	var node_position: Vector3 = _current_chosen_node.position;
	var node_rotation_degrees: Vector3 = _current_chosen_node.rotation_degrees;
	
	var new_node: Node3D;
	match _node_types[ index ]:
		"Blockade":
			new_node = Blockade3D.new();
		"Button":
			new_node = Button3D.new();
		"Finish":
			new_node = Finish3D.new();
		"Lever":
			new_node = Lever3D.new();
		"Moveable":
			new_node = Moveable3D.new();
		"Player":
			new_node = preload("res://prefabs/player/player.tscn").instantiate();
		"Wall":
			new_node = Wall3D.new();
	
	_current_chosen_node.queue_free();
	$NodeContainer.add_child(new_node);
	_current_chosen_node = new_node;
	
	new_node.name = node_name;
	new_node.position = node_position;
	new_node.rotation_degrees = node_rotation_degrees;
	if "paused" in new_node:
		new_node.paused = true;
	
	_refresh_list();
	_update_properties_panel(new_node);

func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/home_scene/home_scene.tscn");

func _update_activator_name(name: String) -> void:
	var placeholder_activator: Activator3D = Activator3D.new();
	placeholder_activator.name = name;
	var blockade: Blockade3D = _current_chosen_node as Blockade3D;
	blockade.activator = placeholder_activator;

func _open_save_dialog() -> void:
	$FileDialog.show();

func _save(path: String) -> void:
	var serialized_map: String = "[\n";
	for node in $NodeContainer.get_children():
		serialized_map += JSON.stringify(node.serialize(), "\t") + ",\n";
	serialized_map += "\n]";
	
	var map_file: FileAccess = FileAccess.open(path, FileAccess.WRITE);
	map_file.store_string(serialized_map);
