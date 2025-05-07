extends Node3D;

var maps: Array[ Variant ];

func _ready() -> void:
	_load_maps();

func _load_maps() -> void:
	var maps_file: FileAccess = FileAccess.open("res://maps/maps.json", FileAccess.READ);
	maps = JSON.parse_string(maps_file.get_as_text());
	
	var list: ItemList = $Menu/FlexBox/MapList;
	for map in maps:
		list.add_item(map.name);

func _get_map_data(path: String) -> Array:
	var map_file: FileAccess = FileAccess.open(path, FileAccess.READ);
	var map_data_string: String = map_file.get_as_text();
	var map_json = JSON.parse_string(map_data_string);
	return map_json;

func _show_map(index: int) -> void:
	var map = _get_map_data(maps[ index ].path);
	Globals.map_data = map;
	$PlayingArea.load_map();

func _start_map() -> void:
	get_tree().change_scene_to_file("res://scenes/playing_area/playing_area.tscn");
