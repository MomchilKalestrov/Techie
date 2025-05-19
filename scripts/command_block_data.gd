extends Object;

class_name CommandBlockData;

var title: String = "";
var color: Color = Color.RED;
var js_code: String = "%0";
var connections_count: int = 1;

func _init(t: String, c: Color, j: String, cc: int) -> void:
	title = t;
	color = c;
	js_code = j;
	connections_count = cc;
