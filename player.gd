extends Node2D

# This script contains behaviour relating to the player character

@export var line_pos: int = 0 # The player's position on the dance line
@export var game: Game # reference to the main game controller
@export var walk_time: float = 0.25 # how many seconds it takes to move one step

 # amplitude of random pitch and volume adjustment for sound effects
@export var pitch_variation: float = 0.1
@export var volume_variation: float = 0.2

@export var duck: bool = false
@export var jump: bool = false
@export var reset: bool = false # exported var that tells enemies when game has a beat because I can't find your thing rn bruh

var single_frame_reset_timer: float = 0 # timer for ending animations with onlly one frame
var next_step_right = true # is the next step right or left foot?

var dodge_sounds: Array
var kill_sounds: Array

# what action is the player currently doing? often read by other scripts
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
	
# Called once every frame
func _process(delta: float) -> void:
	
	# track and potentially end single frame animations
	single_frame_reset_timer -= delta
	if state != PlayerState.NEUTRAL && single_frame_reset_timer <= 0:
		reset_anim()
	
	# switch steps if walk animation is complete
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
	jump = true
	play_random_sound(dodge_sounds)

func dodge_down():
	$AnimatedSprite2D.animation = &"duck"
	state = PlayerState.DUCK
	single_frame_reset_timer = 0.3 # purely visual
	duck = false
	play_random_sound(dodge_sounds)

func move(dir: int) -> void:
	if !game.is_obstructed(line_pos + dir):
		face(dir)
		line_pos = line_pos + dir
	elif game.is_attackable(line_pos + dir):
		face(dir)
		$AnimatedSprite2D.animation = &"attack"
		state = PlayerState.ATTACK
		single_frame_reset_timer = 0.3 # purely visual
		play_random_sound(kill_sounds)
		game.player_attack(line_pos + dir) # dunno how much I like this approach it was last minute

# face the player sprite in x-direction corresponding to the sign of "dir"
func face(dir: int) -> void:
	scale.x = dir

# Play a random sound from "sounds" with randomly adjusted pitch and volume
func play_random_sound(sounds: Array):
	$PlayerSound.stream = sounds[randi() % sounds.size()]
	$PlayerSound.pitch_scale = 1 + randf() * pitch_variation * 2 - pitch_variation
	$PlayerSound.volume_db = linear_to_db(1 + randf() * volume_variation * 2 - volume_variation)
	$PlayerSound.play(0.008) # hacky fix cuz they were starting a bit too late

# Put the player into the correct idle pose
func reset_anim() -> void:
	if next_step_right:
		$AnimatedSprite2D.animation = &"step_right"
		$AnimatedSprite2D.pause()
	else:
		$AnimatedSprite2D.animation = &"step_left"
		$AnimatedSprite2D.pause()

# Called whenever the beginning of a beat input window occurs
func _on_game_rising_edge() -> void:
	# end any dodge or attack state and reset to idle pose so that the character is ready to receive a new input
	if state != PlayerState.NEUTRAL:
		state = PlayerState.NEUTRAL
		reset_anim()
	jump = false
	duck = false
