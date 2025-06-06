@tool
@icon("res://prefabs/finish3d/finish3d.png")
extends Area3D;
class_name Finish3D;

const type: String = "Finish";

func _ready() -> void:
	var mesh: Node3D = preload("res://visual/models/finish/finish.glb").instantiate();
	
	var collision: CollisionShape3D = CollisionShape3D.new();
	collision.shape = BoxShape3D.new();
	collision.shape.size *= 0.5;
	
	add_child(mesh);
	add_child(collision)
	
	body_entered.connect(_finish);

func _finish(body: Node3D) -> void:
	# NOTE:
	if body is CharacterBody3D:
		# Spawning scenes is NOT good
		# practise, BUT in my defence:
		# look up the confetti scene
		# and try to implement it with
		# code only.
		var confetti: Node3D = preload("res://prefabs/finish3d/confetti.tscn").instantiate();
		add_child(confetti);
		for child in confetti.get_children():
			child.emitting = true;
		# Wait for the first confetti to finish.
		await confetti.get_node("Red").finished;
		confetti.queue_free();

func serialize() -> Dictionary:
	return {
		"type": "finish",
		"name": name,
		"position": {
			"x": position.x,
			"y": position.y,
			"z": position.z
		},
		"rotation": {
			"x": rotation_degrees.x,
			"y": rotation_degrees.y,
			"z": rotation_degrees.z
		}
	};
