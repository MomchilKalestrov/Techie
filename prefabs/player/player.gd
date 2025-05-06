extends CharacterBody3D;

var has_reached_destination: bool = false;

var _target_position: Vector3 = Vector3.UP;
var target_position: Vector3:
	get:
		return _target_position;
	set(value):
		has_reached_destination = false;
		_target_position = value;

var _is_facing_wall: bool = false;
var is_facing_wall: bool:
	get:
		return _is_facing_wall;

const save_state: bool = true;

func _ready() -> void:
	Globals.player = self;

func _physics_process(_d: float) -> void:
	# Mrs. Nickolova would probably kill herself if she saw
	# how we calculate the velocity but fuck it we ball
	velocity = (target_position - global_position).snappedf(0.01) * 10;
	if velocity == Vector3.ZERO and not has_reached_destination:
		has_reached_destination = true;
		NodeJs.send_next_command();
	if target_position != global_position.round():
		look_at(target_position);
	
	# return early if the body hasn't collided with anything
	if not move_and_slide():
		return;
	
	for index in get_slide_collision_count():
		var collision: KinematicCollision3D = get_slide_collision(index);
		var collider = collision.get_collider();
		if collider is RigidBody3D:
			collider.apply_force(collision.get_normal() * -15);


func _facing_wall(_body: Node3D) -> void:
	_is_facing_wall = true;

func _not_facing_wall(_body: Node3D) -> void:
	_is_facing_wall = false;
