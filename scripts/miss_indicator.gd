extends Control

var counter: int = 0
var timer: float = 0
var shake_displacement: Vector2 = Vector2(0, 0)
var shake_flip: float = 1
@export var num_shakes: = 5
@export var shake_velocity: Vector2 = Vector2(3, -0.5)
@export var shake_time: float = 0.05
var reset_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		timer -= delta
		position += shake_velocity * shake_flip
		if timer <= 0:
			counter -= 1
			timer = shake_time
			shake_flip *= -1
		if counter <= 0:
			hide()

func fire() -> void:
	show()
	shake_flip = 1
	counter = num_shakes
	timer = shake_time / 2
	shake_displacement = Vector2(0, 0)
	position = reset_position
