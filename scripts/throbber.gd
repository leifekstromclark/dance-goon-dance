extends Control

@export var throb_time: float = 0.2
@export var vertical_throb: float = 1.1
@export var horizontal_throb: float = 1.1
@export var music_manager: MusicManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# throb, centered on beats
	if abs(music_manager.get_error()) <= throb_time / 2:
		scale = Vector2(horizontal_throb, vertical_throb)
	else:
		scale = Vector2(1, 1)
