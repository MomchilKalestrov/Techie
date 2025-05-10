extends Node3D;

class_name Activator3D;

signal active();
signal inactive();

func is_active() -> bool:
		push_error("Is active not implemented");
		return false;
