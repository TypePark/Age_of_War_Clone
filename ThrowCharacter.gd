extends Node2D

enum Directions { RIGHT, LEFT }
enum States { SELECTDIR, STRETCH, WAIT }

@export_group("References")
@export var arrow: Node2D
@export var targetPos: Node2D
@export var Obstacle: PackedScene

@export_group("Settings")
@export var input_action: StringName = &"player1"
@export var CharacterFacingDirection: Directions = Directions.RIGHT
@export var rotationSpeed: float = 3.0
@export var throwForce: float = 100.0
@export var State: States = States.SELECTDIR

var throwScale: float = 0.0
var direction: float = -1.0
var direction1: float = -1.0

# Angle limits derived from facing direction
var _center_angle: float
var _half_span: float
var _min_angle: float
var _max_angle: float


func _ready() -> void:
	match CharacterFacingDirection:
		Directions.RIGHT:
			scale.x = abs(scale.x)
			# Sweeps between -100° (up-right) and +20° (down-right) -> Center: -40°, Span: ±60°
			_center_angle = -40.0
			_half_span = 60.0
			_min_angle = -100.0
			_max_angle = 20.0
		Directions.LEFT:
			scale.x = -abs(scale.x)
			# Sweeps between -200° (down-left) and -100° (up-left) -> Center: -150°, Span: ±50°
			_center_angle = -150.0
			_half_span = 50.0
			_min_angle = -200.0
			_max_angle = -100.0

	# Initialize arrow inside the valid sweep arc
	if arrow:
		arrow.global_rotation_degrees = _center_angle


func _process(delta: float) -> void:
	match State:
		States.SELECTDIR:
			_handle_aiming(delta)
		States.STRETCH:
			_handle_power(delta)
		States.WAIT:
			pass


func _handle_aiming(delta: float) -> void:
	var rel: float = wrapf(arrow.global_rotation_degrees - _center_angle, -180.0, 180.0)

	if rel > _half_span:
		direction = -1.0
		arrow.global_rotation_degrees = _max_angle
	elif rel < -_half_span:
		direction = 1.0
		arrow.global_rotation_degrees = _min_angle

	arrow.rotate(delta * rotationSpeed * direction)

	if Input.is_action_just_pressed(input_action):
		State = States.STRETCH


func _handle_power(delta: float) -> void:
	if throwScale >= 1.0:
		throwScale = 1.0
		direction1 = -1.0
	elif throwScale <= 0.0:
		throwScale = 0.0
		direction1 = 1.0

	throwScale += direction1 * delta * rotationSpeed
	arrow.scale.x = 0.01 + 0.2 * throwScale

	if Input.is_action_just_pressed(input_action):
		_throw_obstacle()
		State = States.SELECTDIR


func _throw_obstacle() -> void:
	var obj = Obstacle.instantiate()
	get_tree().current_scene.add_child(obj)
	obj.global_position = targetPos.global_position
	
	var dir: Vector2 = Vector2.RIGHT.rotated(arrow.global_rotation)
	obj.linear_velocity = dir * throwScale * throwForce
