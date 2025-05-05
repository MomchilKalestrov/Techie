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
	var map_data_string: String = "";
	
	if $Container/MapUrl.text != "":
		var status: Error = $HTTPRequest.request($Container/MapUrl.text);
		if status != OK:
			return;
			
		var params: Array = await $HTTPRequest.request_completed;
		var response_code: int = params[ 1 ];
		var body: PackedByteArray = params[ 3 ];
		
		if response_code < 200 or response_code > 299:
			return;
		
		map_data_string = body.get_string_from_utf8();
	
	# if the map_data_string is still empty
	# then that means the URL was invalid
	# or it wasn't provided
	if map_data_string == "":
		var map_path: String = maps[ $Container/Maps.selected ].path;
		var map_file: FileAccess = FileAccess.open(map_path, FileAccess.READ);
		map_data_string = map_file.get_as_text();
	
	var map_json = JSON.parse_string(map_data_string);
	if typeof(map_json) != TYPE_ARRAY:
		return;
	Globals.map_data = map_json;
	get_tree().change_scene_to_file("res://scenes/playing_area/playing_area.tscn");
