extends Control;

var maps: Array[ Variant ];

func _ready() -> void:
	_load_maps();

func _load_maps() -> void:
	var maps_file: FileAccess = FileAccess.open("res://maps/maps.json", FileAccess.READ);
	maps = JSON.parse_string(maps_file.get_as_text());
	
	var options: OptionButton = $Container/Maps;
	for map in maps:
		options.add_item(map.name);

func _start_map() -> void:
	var map_path: String = maps[ $Container/Maps.selected ].path;
	var map_file: FileAccess = FileAccess.open(map_path, FileAccess.READ);
	Globals.map_data = JSON.parse_string(map_file.get_as_text());
	get_tree().change_scene_to_file("res://scenes/playing_area/playing_area.tscn");
