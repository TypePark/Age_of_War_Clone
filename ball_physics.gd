extends Node2D
@export var ball_scene: PackedScene = preload("res://GameObjects/ball.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		spawn_ball(get_global_mouse_position())

func spawn_ball(spawn_position: Vector2 ) -> void:
	var new_ball = ball_scene.instantiate()
	new_ball.global_position = spawn_position
	add_child(new_ball)
