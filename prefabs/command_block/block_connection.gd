# Code's pretty self explanatory.
# All I can mention is that it was
# a pain in the ass to implement.
extends Panel;
class_name BlockConnection;

signal block_connected();

const DEFAULT_CONNECTION_HEIGHT: int = 8;

var connected_block: CommandBlock;

func get_rectangle() -> Rect2:
	return Rect2(global_position, size);

func can_connect(point: Vector2) -> bool:
	return get_rectangle().has_point(point);

func connect_block(block: CommandBlock) -> void:
	connected_block = block;
	block.parent_connection = self;
	block_connected.emit();
