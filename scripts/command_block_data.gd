extends Object;

class_name CommandBlockData;

@export var title: String = "";
@export var color: Color = Color.RED;
@export var js_code: String = "";

func _init(t: String, c: Color, j: String) -> void:
	title = t;
	color = c;
	js_code = j;
