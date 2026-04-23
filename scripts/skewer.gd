extends Node2D

@export var vertical_stretch: float = 1.1
@export var skew_intensity: float = 0.1

func setup(music_manager: MusicManager) -> void:
	music_manager.beat.connect(self._on_music_manager_beat)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_music_manager_beat(n: int) -> void:
	if n % 4 == 0:
		scale.y = vertical_stretch
		skew = -skew_intensity
	elif n % 4 == 2:
		scale.y = vertical_stretch
		skew = skew_intensity
	else:
		scale.y = 1
		skew = 0
		
