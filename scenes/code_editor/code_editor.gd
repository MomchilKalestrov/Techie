extends Control;

const _initial_console_string = "Console:\n";
var _is_block_editor: bool = false;

const _highlighter: Dictionary[ Color, Array ] = {
	Color("#ce8f5e"): [ "region", [ "\"|\"", "'|'", "`|`" ] ],
	Color("#6a954e"): [ "region", [ "//|", "/*|*/" ] ],
	Color("#c081bb"): [ "keyword", [
		"await", "break", "case", "catch", "continue", "default",
		"do", "else", "package", "return", "switch", "try", "export",
		"finally", "while", "with", "yield", "if", "import", "throw",
		"from", "for", "extends"
	] ],
	Color("#3276d0"): [ "keyword", [
		"function", "arguments", "class", "const", "debugger", "delete",
		"enum", "false", "implements", "in", "instanceof", "interface",
		"let", "new", "null", "private", "protected", "public", "static",
		"super", "this", "true", "typeof", "var", "void"
	] ],
	Color("#f8c80d"): [ "keyword", [ "{", "}", "(", ")", "[", "]" ] ]
};

func _ready() -> void:
	# Add pretty colors to the JS editor.
	var syntax_highlighter: CodeHighlighter = $Main/Ide.syntax_highlighter;
	for color in _highlighter.keys():
		var highlight = _highlighter[ color ];
		match highlight[ 0 ]:
			"region":
				for token: String in highlight[ 1 ]:
					var start_end: PackedStringArray = token.split("|");
					syntax_highlighter.add_color_region(start_end[ 0 ], start_end[ 1 ], color);
			"keyword":
				for token: String in highlight[ 1 ]:
					syntax_highlighter.add_keyword_color(token, color);
	
	$Main/Logger.text = _initial_console_string;

func _run() -> void:
	Globals.world.reset();
	JS.instatiate_environment($Main/CommandEditor.extract_js_code() if _is_block_editor else $Main/Ide.text, _log);

func _toggle_editor() -> void:
	_is_block_editor = not _is_block_editor;
	$Main/Ide.visible = not _is_block_editor;
	$Main/CommandEditor.visible = _is_block_editor;

func _stop() -> void:
	$Main/Logger.text = _initial_console_string;
	Globals.world.reset();
	JS.kill_node_js();

func _back() -> void:
	for node in get_tree().current_scene.get_children(true):
		node.queue_free();
	get_tree().change_scene_to_file("res://scenes/home_scene/home_scene.tscn");

func _log(text: String) -> void:
	$Main/Logger.text += text + "\n";
