extends Node3D;

var maps: Dictionary[ String, String ];

var _has_selected_map: bool = false;

func _ready() -> void:
	_load_maps();

func _get_all_files(path: String) -> Array[ String ]:
	var files: Array[ String ] = [];
	
	var dir = DirAccess.open(path);
	if dir == null:
		return files;
	
	dir.list_dir_begin();
	var element_name = dir.get_next();
	while element_name != "":
		if not dir.current_is_dir():
			files.push_front(element_name);
		element_name = dir.get_next();
	
	return files;

func _format_file_names(names: Array[ String ]) -> Dictionary[ String, String ]:
	var formatted_names: Dictionary[ String, String ] = {};
	
	for map_name in names:
		var formatted_name = ".".join(map_name.split(".").slice(0, -1)).capitalize();
		formatted_names[ formatted_name ] = map_name;
	
	return formatted_names;

func _load_maps() -> void:
	var map_paths: Array[ String ] = _get_all_files("res://maps");
	map_paths.sort();
	var names: Dictionary[ String, String ] = _format_file_names(map_paths);
	maps = names;
	
	var list: ItemList = $MapsMenu/FlexBox/MapList;
	for map in maps.keys():
		list.add_item(map);

func _get_map_data(path: String) -> Array:
	var map_file: FileAccess = FileAccess.open("res://maps/" + path, FileAccess.READ);
	var map_data_string: String = map_file.get_as_text();
	var map_json: Array = JSON.parse_string(map_data_string);
	return map_json;

func _show_map(index: int) -> void:
	_has_selected_map = true;
	var map = _get_map_data(maps[ maps.keys()[ index ] ]);
	Globals.map_data = map;
	$MapLoader.load_map();

func _start_map(force: bool = false) -> void:
	if _has_selected_map or force:
		get_tree().change_scene_to_file("res://scenes/playing_area/playing_area.tscn");

var _is_downloaded_map: bool = false;
func _toggle_download_map() -> void:
	_is_downloaded_map = not _is_downloaded_map;
	$MapsMenu.visible = not _is_downloaded_map;
	$DownloadMenu.visible = _is_downloaded_map;

func _download_and_load_map() -> void:
	if $DownloadMenu/FlexBox/URL.text == "":
		return;
	$HTTPRequest.request($DownloadMenu/FlexBox/URL.text);
	var returns = await $HTTPRequest.request_completed;
	var body: PackedByteArray = returns[ 3 ];
	var map_data_string: String = body.get_string_from_utf8();
	var map_json = JSON.parse_string(map_data_string);
	if map_json == null:
		return;
	Globals.map_data = map_json;
	_start_map(true);


func _open_editor() -> void:
	Globals.map_data = [];
	get_tree().change_scene_to_file("res://scenes/map_editor/map_editor.tscn");
