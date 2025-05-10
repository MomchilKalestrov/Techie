extends Node3D;

var maps: Array[ Variant ];

var _has_selected_map: bool = false;

func _ready() -> void:
	_load_maps();

func _load_maps() -> void:
	var maps_file: FileAccess = FileAccess.open("res://maps/maps.json", FileAccess.READ);
	maps = JSON.parse_string(maps_file.get_as_text());
	
	var list: ItemList = $MapsMenu/FlexBox/MapList;
	for map in maps:
		list.add_item(map.name);

func _get_map_data(path: String) -> Array:
	var map_file: FileAccess = FileAccess.open(path, FileAccess.READ);
	var map_data_string: String = map_file.get_as_text();
	var map_json = JSON.parse_string(map_data_string);
	return map_json;

func _show_map(index: int) -> void:
	_has_selected_map = true;
	var map = _get_map_data(maps[ index ].path);
	Globals.map_data = map;
	$PlayingArea.load_map();

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
	var response_code: int = returns[ 1 ];
	var body: PackedByteArray = returns[ 3 ];
	var map_data_string: String = body.get_string_from_utf8();
	var map_json = JSON.parse_string(map_data_string);
	if map_json == null:
		return;
	Globals.map_data = map_json;
	_start_map(true);
