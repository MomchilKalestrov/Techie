extends CommandBlock;
class_name ConditionalBlock;

var _condition: Condition;

func _init() -> void:
	connection_count = 2;
	super._init();

func _ready() -> void:
	super._ready();
	color = Color.REBECCA_PURPLE;

func can_connect(pos: Vector2) -> bool:
	return Rect2(position, size).has_point(pos);

func extract_js_code() -> String:
	var base_result: String = super.extract_js_code();
	return base_result.replace("%c", _condition.js_code if _condition != null else "false");

func replace_condition(new_condition: Condition) -> void:
	if _condition != null:
		_condition.queue_free();
	
	_condition = new_condition;
	new_condition.parent_block = self;
