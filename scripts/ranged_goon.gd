extends Node2D
class_name RangedGoon

var line_pos = 0
var game: Game
var music_manager: MusicManager

@export var walk_time: float = 0.25 # how many seconds it takes to move one step

enum EnemyState {SPOTTED, CHARGEHIGH, CHARGELOW, ATTACKHIGH, ATTACKLOW, NEUTRAL}
var state: EnemyState = EnemyState.NEUTRAL

var attack_anim_timer: float
var attack_offset: int = -10

var damaged: bool = false

var goon_spell_shattered: Texture2D
var dead_goon_scene: PackedScene
var dead_goon_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(game.real_xpos(line_pos), game.line_y)
	music_manager.beat.connect(self._on_music_manager_beat)
	game.falling_edge.connect(self._on_falling_edge)
	game.rising_edge.connect(self._on_rising_edge)
	$Throbber.music_manager = music_manager
	goon_spell_shattered = preload("res://goons/art/goonspellshattered.png")
	dead_goon_scene = preload("res://goons/dead_goon.tscn")
	dead_goon_texture = preload("res://goons/art/RangeDefeat.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$HighLaserMain.set_frame_and_progress($HighLaserStart.get_frame(), $HighLaserStart.get_frame_progress())
	$LowLaserMain.set_frame_and_progress($LowLaserStart.get_frame(), $LowLaserStart.get_frame_progress())
	if state == EnemyState.ATTACKHIGH || state == EnemyState.ATTACKLOW:
		attack_anim_timer -= delta
		if attack_anim_timer <= 0:
			reset_anim()
	
	# move goon
	var move_target = game.real_xpos(line_pos)
	if position.x != move_target:
		if move_target > position.x:
			position.x = min(position.x + game.line_cell_size / walk_time * delta, move_target)
		else:
			position.x = max(position.x - game.line_cell_size / walk_time * delta, move_target)
	
func face(dir: int) -> void:
	scale.x = dir

func _on_music_manager_beat(n: int) -> void:
	var player_disp = game.get_player_line_pos() - line_pos
	face(sign(player_disp))
	
	reset_anim()
	
	if state == EnemyState.SPOTTED:
		if abs(player_disp) <= 5:
			if n % 8 == 1:
				state = EnemyState.CHARGEHIGH
				$Throbber/Main.animation = &"charge_high"
				$HighTwinkle.show()
				$HighTwinkle.play()
			elif n % 8 == 3:
				state = EnemyState.CHARGELOW
				$Throbber/Main.animation = &"charge_low"
				$LowTwinkle.show()
				$LowTwinkle.play()
		elif !game.is_obstructed(line_pos + sign(player_disp)):
			# this should be fine for now but might break as things scale
			line_pos += sign(player_disp)
			
	elif state == EnemyState.CHARGEHIGH:
		state = EnemyState.ATTACKHIGH
		position.x += attack_offset * sign(player_disp)
		attack_anim_timer = 0.3
		$Throbber/Main.animation = &"attack_high"
		$HighLaserStart.show()
		$HighLaserMain.show()
		$HighLaserStart.play()
	elif state == EnemyState.CHARGELOW:
		state = EnemyState.ATTACKLOW
		position.x += attack_offset * sign(player_disp)
		attack_anim_timer = 0.3
		$Throbber/Main.animation = &"attack_low"
		$LowLaserStart.show()
		$LowLaserMain.show()
		$LowLaserStart.play()

func reset_anim() -> void:
	position.x = game.real_xpos(line_pos)
	$Throbber/Main.animation = &"default"

func _on_falling_edge() -> void:
	var player_disp = game.get_player_line_pos() - line_pos
	if state == EnemyState.ATTACKHIGH:
		if game.get_player_state() != Player.State.DUCK:
			game.hit_player()
	elif state == EnemyState.ATTACKLOW:
		if game.get_player_state() != Player.State.JUMP:
			game.hit_player()
	elif abs(player_disp) <= 4 && state == EnemyState.NEUTRAL:
		state = EnemyState.SPOTTED
		$Throbber/Main.animation = &"spotted"
		$Spot.show()
		$Spot.play()

func _on_rising_edge() -> void:
	if state == EnemyState.ATTACKHIGH || state == EnemyState.ATTACKLOW:
		state = EnemyState.SPOTTED

func damage() -> void:
	damaged = true
	$Throbber/Main/GoonSpell.texture = goon_spell_shattered

func die() -> void:
	self.queue_free()
	var dead_goon = dead_goon_scene.instantiate()
	dead_goon.set_texture(dead_goon_texture)
	dead_goon.position = position
	game.add_child(dead_goon)


func _on_high_twinkle_animation_finished() -> void:
	$HighTwinkle.hide()


func _on_low_twinkle_animation_finished() -> void:
	$LowTwinkle.hide()


func _on_spot_animation_finished() -> void:
	$Spot.hide()


func _on_low_laser_start_animation_finished() -> void:
	$LowLaserStart.hide()
	$LowLaserMain.hide()


func _on_high_laser_start_animation_finished() -> void:
	$HighLaserStart.hide()
	$HighLaserMain.hide()
