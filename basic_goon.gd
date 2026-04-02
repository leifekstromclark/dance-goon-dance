extends Node2D
class_name BasicGoon

# Right now he doesnt do shit!

var line_pos = 0
var game: Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(game.real_xpos(line_pos), game.line_y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass	
