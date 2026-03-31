extends Node2D
class_name BasicGoon

var line_pos = 0
var charge = 0
var game: Game
var attacking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(game.real_xpos(line_pos), game.line_y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass	


'''
func _on_music_manager_beat(n: int) -> void:
	# Right now we arent accounting for audioplayer latency for sound effects
	# I'm hoping we don't have to
	if abs(game.get_player_line_pos() - line_pos) == 1 && charge == 0:
		charge = game.get_player_line_pos() - line_pos
		# telegraph
	elif charge != 0:
		# attack anim
		attacking = true
'''
