extends Node3D;

class_name Activator3D;

@warning_ignore("unused_signal")
signal active();
@warning_ignore("unused_signal")
signal inactive();

func is_active() -> bool:
		return false;
