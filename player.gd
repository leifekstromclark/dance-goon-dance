extends Node2D

@export var line_pos: int = 0
@export var game: Game
@export var walk_time: float = 0.25
@export var pitch_variation: float = 0.1
@export var volume_variation: float = 0.2

var single_frame_reset_timer = 0
var next_step_right = true

var dodge_sounds: Array
var kill_sounds: Array

enum PlayerState {JUMP, DUCK, ATTACK, NEUTRAL}

var state: PlayerState = PlayerState.NEUTRAL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(game.real_xpos(line_pos), game.line_y)
	$AnimatedSprite2D.sprite_frames.set_animation_speed(&"step_left", $AnimatedSprite2D.sprite_frames.get_frame_count(&"step_left") / walk_time)
	$AnimatedSprite2D.sprite_frames.set_animation_speed(&"step_right", $AnimatedSprite2D.sprite_frames.get_frame_count(&"step_right") / walk_time)
	dodge_sounds.push_back(preload("res://sounds/MichaelCha.wav"))
	dodge_sounds.push_back(preload("res://sounds/MichaelDah.wav"))
	dodge_sounds.push_back(preload("res://sounds/MichaelInhale.wav"))
	kill_sounds.push_back(preload("res://sounds/MichaelShookachooka.wav"))
	kill_sounds.push_back(preload("res://sounds/MichaelOW.wav"))
	kill_sounds.push_back(preload("res://sounds/MichaelHOO.wav"))
	kill_sounds.push_back(preload("res://sounds/whip.wav"))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# process single frame animations
	single_frame_reset_timer -= delta
	if state != PlayerState.NEUTRAL && single_frame_reset_timer <= 0:
		reset_anim()
	
	# switch steps if walk animation done
	if !$AnimatedSprite2D.is_playing() && $AnimatedSprite2D.frame != 0 && ($AnimatedSprite2D.animation == &"step_right" || $AnimatedSprite2D.animation == &"step_left"):
		next_step_right = !next_step_right
		reset_anim()
	
	# move player if necessary
	var move_target = game.real_xpos(line_pos)
	if position.x != move_target:
		$AnimatedSprite2D.play()
		if move_target > position.x:
			position.x = min(position.x + game.line_cell_size / walk_time * delta, move_target)
		else:
			position.x = max(position.x - game.line_cell_size / walk_time * delta, move_target)

func dodge_up():
	$AnimatedSprite2D.animation = &"jump"
	state = PlayerState.JUMP
	single_frame_reset_timer = 0.3 # purely visual
	play_random_sound(dodge_sounds)

func dodge_down():
	$AnimatedSprite2D.animation = &"duck"
	state = PlayerState.DUCK
	single_frame_reset_timer = 0.3 # purely visual
	play_random_sound(dodge_sounds)

func move(dir: int) -> void:
	if !game.is_obstructed(line_pos + dir):
		face(dir)
		line_pos = line_pos + dir
	elif game.is_attackable(line_pos + dir):
		face(dir)
		$AnimatedSprite2D.animation = &"attack"
		state = PlayerState.ATTACK
		single_frame_reset_timer = 0.3
		play_random_sound(kill_sounds)
		game.player_attack(line_pos + dir)

func face(dir: int) -> void:
	scale.x = dir

func play_random_sound(sounds: Array):
	$PlayerSound.stream = sounds[randi() % sounds.size()]
	$PlayerSound.pitch_scale = 1 + randf() * pitch_variation * 2 - pitch_variation
	$PlayerSound.volume_db = linear_to_db(1 + randf() * volume_variation * 2 - volume_variation)
	$PlayerSound.play(0.008) # hacky fix cuz they were starting a bit too late

func reset_anim() -> void:
	if next_step_right:
		$AnimatedSprite2D.animation = &"step_right"
		$AnimatedSprite2D.pause()
	else:
		$AnimatedSprite2D.animation = &"step_left"
		$AnimatedSprite2D.pause()

func _on_game_rising_edge() -> void:
	if state != PlayerState.NEUTRAL:
		state = PlayerState.NEUTRAL
		reset_anim()
