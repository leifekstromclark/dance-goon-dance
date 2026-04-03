extends Node2D
class_name BasicGoon

var line_pos = 0
var game: Game

@export var cooldown: int = 0

var playerDistance: int = 0
var telegraphed: bool = false

enum EnemyState {SPOTTED, CHARGEHIGH, CHARGELOW, ATTACKHIGH, ATTACKLOW, NEUTRAL}
var state: EnemyState = EnemyState.NEUTRAL

var attack_anim_timer: float
var attack_offset: int = 40


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(game.real_xpos(line_pos), game.line_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if state == EnemyState.ATTACKHIGH || state == EnemyState.ATTACKLOW:
		attack_anim_timer -= delta
		if attack_anim_timer <= 0:
			reset_anim()
	
func face(dir: int) -> void:
	scale.x = dir

func _on_music_manager_beat(_n: int) -> void:
	print(state)
	var player_disp = game.get_player_line_pos() - line_pos
	face(sign(player_disp))
	
	reset_anim()
	
	if abs(player_disp) > 2:
		state = EnemyState.NEUTRAL
		$AnimatedSprite2D.animation = &"default"
	elif state == EnemyState.SPOTTED:
		var r = randi() % 2
		if r == 0:
			state = EnemyState.CHARGEHIGH
			$AnimatedSprite2D.animation = &"charge_high"
		else:
			state = EnemyState.CHARGELOW
			$AnimatedSprite2D.animation = &"charge_low"
	elif state == EnemyState.CHARGEHIGH:
		state = EnemyState.ATTACKHIGH
		position.x += attack_offset * player_disp
		attack_anim_timer = 0.2
		$AnimatedSprite2D.animation = &"attack_high"
	elif state == EnemyState.CHARGELOW:
		state = EnemyState.ATTACKLOW
		position.x += attack_offset * player_disp
		attack_anim_timer = 0.2
		$AnimatedSprite2D.animation = &"attack_low"

func reset_anim() -> void:
	position.x = game.real_xpos(line_pos)
	$AnimatedSprite2D.animation = &"spotted"

func _on_falling_edge() -> void:
	var player_disp = game.get_player_line_pos() - line_pos
	if state == EnemyState.ATTACKHIGH:
		state = EnemyState.SPOTTED
		if abs(player_disp) <= 1 && game.get_player_state() != Player.PlayerState.DUCK:
			game.hit_player()
	elif state == EnemyState.ATTACKLOW:
		state = EnemyState.SPOTTED
		if abs(player_disp) <= 1 && game.get_player_state() != Player.PlayerState.JUMP:
			game.hit_player()
	if abs(player_disp) <= 2 && state == EnemyState.NEUTRAL:
		state = EnemyState.SPOTTED
		$AnimatedSprite2D.animation = &"spotted"
	
