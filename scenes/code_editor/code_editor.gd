extends Control;

const _initial_console_string = "Console:\n";

func _ready() -> void:
	$Main/Logger.text = _initial_console_string;

func _run() -> void:
	Globals.world.reset();
	NodeJs.instatiate_node_js($Main/Ide.text, _log);

func _toggle_editor() -> void:
	$Main.visible = !$Main.visible;

func _stop() -> void:
	$Main/Logger.text = _initial_console_string;
	Globals.world.reset();
	NodeJs.kill_node_js();

func _back() -> void:
	for node in get_tree().current_scene.get_children(true):
		node.queue_free();
	get_tree().change_scene_to_file("res://scenes/home_scene/home_scene.tscn");

func _log(text: String) -> void:
	$Main/Logger.text += text + "\n";
