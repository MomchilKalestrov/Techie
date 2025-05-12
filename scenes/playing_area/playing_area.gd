extends Node3D;

func _is_withing_rect(box_start: Vector2, box_end: Vector2, point: Vector2) -> bool:
	return box_start.x < point.x and box_end.x > point.x and box_start.y < point.y and box_end.y > point.y;

var _is_dragging: bool = false;
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var dragger_position: Vector2 = $SplitContainer/Window/DragRegion.global_position;
		var dragger_size: Vector2 = $SplitContainer/Window/DragRegion.size;
		_is_dragging = _is_withing_rect(dragger_position, dragger_position + dragger_size, event.global_position) and not _is_dragging;
	
	if event is InputEventMouseMotion and _is_dragging:
		$MapLoader/CameraPivot.rotation_degrees.y += event.screen_relative.x;
