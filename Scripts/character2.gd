extends Node2D

@export var arrow:Node2D
@export var rotationSpeed:float=3
@export var throwForce:float=100.0;
enum Directions{
	RIGHT,
	LEFT
}
@export var CharacterFacingDirection:Directions= Directions.RIGHT;
var minRot=20;
var maxRot=-100;
enum States{
	SELECTDIR,
	STRETCH,
	WAIT
}
var angle:float=-180;
var throwScale:float=0.0;
@export var State:States=States.SELECTDIR;
@export var Obstacle:PackedScene;
@export var targetPos:Node2D ;
var direction:float=-1.0;
var direction1:float=-1.0;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match CharacterFacingDirection:
		Directions.RIGHT:
			scale.x*=1;
		Directions.LEFT:
			scale.x*=-1;


func _process(delta: float) -> void:
	match State:
		States.SELECTDIR:
			var rel = wrapf(arrow.global_rotation_degrees + 150.0, -180.0, 180.0)
			if rel > 50.0:            # -100'ü geçti
				direction = -1
				arrow.global_rotation_degrees = -100.0
			elif rel < -50.0:         # -200'ü geçti
				direction = 1
				arrow.global_rotation_degrees = -200.0
			arrow.rotate(delta * rotationSpeed * direction)
			if(Input.is_action_just_pressed("player2")):
				State=States.STRETCH;
		States.STRETCH:
			if(throwScale>1.0):
				throwScale=1.0;
				direction1*=-1;
			elif(throwScale<0.0):
				throwScale=0.0;
				direction1*=-1;
			throwScale+=direction1*delta*rotationSpeed;
			arrow.scale.x=0.01+0.2*throwScale;
			if(Input.is_action_just_pressed("player2")):
				var obj = Obstacle.instantiate();
				get_tree().current_scene.add_child(obj)
				obj.global_position = targetPos.global_position
				var dir = Vector2.RIGHT.rotated(arrow.global_rotation)
				obj.linear_velocity = dir * throwScale * throwForce
				State=States.SELECTDIR;
				
		States.WAIT:
			pass
