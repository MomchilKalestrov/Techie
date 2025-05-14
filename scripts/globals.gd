extends Node;

var player: CharacterBody3D;
var world: Node3D;
var map_data: Array[ Variant ] = [];

func get_script_by_name(c_name:String) -> Script:
	if ResourceLoader.exists(c_name, "Script"):
		return load(c_name) as Script;
	
	for global_class in ProjectSettings.get_global_class_list():
		var found_class: String = global_class["class"];
		var found_path: String = global_class["path"];
		if found_class == c_name:
			return load(found_path) as Script;
	
	return null

func instantiate_class(c_name: String) -> Object:
	if c_name.is_empty():
		return null;

	var result: Object = null;
	if ClassDB.class_exists(c_name):
		result = ClassDB.instantiate(c_name);
	else:
		var script := get_script_by_name(c_name);
		if script is GDScript:
			result = (script as GDScript).new()
	
	return result;

func try_get_node(node: Node, path: String) -> Variant:
	if node.has_node(path):
		return node.get_node(path);
	return null;

func set_map_node_state(node: Node3D, state: Variant) -> void:
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
	
	match state.type:
		"wall":
			node.size = Vector2(state.size.x, state.size.y);
		"player":
			node.target_position = Vector3(
				state.position.x,
				state.position.y,
				state.position.z
			);
			node.target_rotation = state.rotation.y;
