extends Control

@export var tutorial3: AudioWrapper

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MusicManager.play_song(tutorial3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
