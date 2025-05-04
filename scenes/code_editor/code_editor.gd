extends Control;

func run() -> void:
	Globals.world.reset();
	NodeJs.instatiate_node_js($Ide.text);

func toggle_editor() -> void:
	$Ide.visible = !$Ide.visible;
	print($Ide.visible);

func stop() -> void:
	Globals.world.reset();
	NodeJs.kill_node_js();
