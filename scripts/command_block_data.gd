extends Object;

class_name CommandBlockData;

var title: String = "";
var color: Color = Color.RED;
var js_code: String = "%0";
var connections_count: int = 1;
var block_class: String = "CommandBlock";

func _init(t: String, c: Color, j: String, cc: int, bc: String = "CommandBlock") -> void:
	title = t;
	color = c;
	js_code = j;
	connections_count = cc;
	block_class = bc;
