extends CharacterBody3D;

const type: String = "Player";

var has_reached_destination: bool = false;

var _target_position: Vector3;
var target_position: Vector3:
	get:
		return _target_position;
	set(value):
		has_reached_destination = false;
		_target_position = value;

var has_reached_rotation: bool = false;

var _target_rotation: float = 0.0;
var target_rotation: float:
	get:
		return _target_rotation;
	set(value):
		has_reached_rotation = false;
		_target_rotation = value;

var _is_facing_wall: bool = false;

const save_state: bool = true;

func _ready() -> void:
	Globals.player = self;
	_target_position = global_position;

func _physics_process(delta: float) -> void:
	# Patch by Sonnet to fix a bug where the player
	# spinned uncontrollably.
	var shortest_angle = wrapf(target_rotation - rotation_degrees.y, -180.0, 180.0)
	rotation_degrees.y = rotation_degrees.y + shortest_angle * min(1, delta * 10)
	
	# Mrs. Nickolova would probably kill herself if she saw
	# how we calculate the velocity but fuck it we ball
	velocity = (target_position - global_position).snappedf(0.01) * 10;
	if velocity == Vector3.ZERO and not has_reached_destination:
		has_reached_destination = true;
		JS.send_next_command();
	elif abs(shortest_angle) < 0.1 and not has_reached_rotation:
		has_reached_rotation = true;
		JS.send_next_command(); 
	
	# return early if the body hasn't collided with anything
	if not move_and_slide():
		return;
	
	# kick any physics body in the way (most likely a box of sorts)
	for index in get_slide_collision_count():
		var collision: KinematicCollision3D = get_slide_collision(index);
		var collider = collision.get_collider();
		if collider is RigidBody3D:
			collider.apply_force(collision.get_normal() * -15);

func _facing_wall(body: Node3D) -> void:
	_is_facing_wall = body is StaticBody3D or _is_facing_wall;

func _not_facing_wall(_body: Node3D) -> void:
	await get_tree().process_frame;
	var areas = $WallCheck.get_overlapping_areas();
	for area in areas:
		if area is Wall3D:
			return;
	_is_facing_wall = false;

func move_forwards() -> void:
	target_position += Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(target_rotation));
	
func move_backwards() -> void:
	target_position += Vector3.BACK.rotated(Vector3.UP, deg_to_rad(target_rotation));

func turn_left() -> void:
	target_rotation = fmod(target_rotation + 90.0, 360.0);

func turn_right() -> void:
	target_rotation = fmod(target_rotation - 90.0 + 360.0, 360.0);

func interract() -> void:
	var areas: Array[ Area3D ] = $WallCheck.get_overlapping_areas();
	for area in areas:
		if area.has_method("interract"):
			area.interract();

func is_facing_wall() -> bool:
	print(_is_facing_wall);
	return _is_facing_wall;

func serialize() -> Dictionary:
	return {
		"type": "player",
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
