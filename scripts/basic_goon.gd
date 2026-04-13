extends Node2D
class_name BasicGoon

var line_pos = 0
var game: Game
var music_manager: MusicManager

@export var cooldown: int = 0

var playerDistance: int = 0
var telegraphed: bool = false

enum EnemyState {SPOTTED, CHARGEHIGH, CHARGELOW, ATTACKHIGH, ATTACKLOW, NEUTRAL}
var state: EnemyState = EnemyState.NEUTRAL

var attack_anim_timer: float
var attack_offset: int = 30

var damaged: bool = false

var goon_spell_shattered: Texture2D
var dead_goon_scene: PackedScene
var dead_goon_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(game.real_xpos(line_pos), game.line_y)
	music_manager.beat.connect(self._on_music_manager_beat)
	game.falling_edge.connect(self._on_falling_edge)
	$Throbber.music_manager = music_manager
	goon_spell_shattered = preload("res://goons/goonspellshattered.png")
	dead_goon_scene = preload("res://dead_goon.tscn")
	dead_goon_texture = preload("res://goons/BaseDefeat.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == EnemyState.ATTACKHIGH || state == EnemyState.ATTACKLOW:
		attack_anim_timer -= delta
		if attack_anim_timer <= 0:
			reset_anim()
	
func face(dir: int) -> void:
	scale.x = dir

func _on_music_manager_beat(n: int) -> void:
	var player_disp = game.get_player_line_pos() - line_pos
	face(sign(player_disp))
	
	reset_anim()
	
	if abs(player_disp) > 2:
		state = EnemyState.NEUTRAL
		$Throbber/Main.animation = &"default"
	elif state == EnemyState.SPOTTED:
		if n % 4 == 1:
			state = EnemyState.CHARGEHIGH
			$Throbber/Main.animation = &"charge_high"
			$HighTwinkle.show()
			$HighTwinkle.play()
		elif n % 4 == 3:
			state = EnemyState.CHARGELOW
			$Throbber/Main.animation = &"charge_low"
			$LowTwinkle.show()
			$LowTwinkle.play()
	elif state == EnemyState.CHARGEHIGH:
		state = EnemyState.ATTACKHIGH
		position.x += attack_offset * sign(player_disp)
		attack_anim_timer = 0.2
		$Throbber/Main.animation = &"attack_high"
	elif state == EnemyState.CHARGELOW:
		state = EnemyState.ATTACKLOW
		position.x += attack_offset * sign(player_disp)
		attack_anim_timer = 0.2
		$Throbber/Main.animation = &"attack_low"

func reset_anim() -> void:
	position.x = game.real_xpos(line_pos)
	$Throbber/Main.animation = &"spotted"

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
	elif abs(player_disp) <= 2 && state == EnemyState.NEUTRAL:
		state = EnemyState.SPOTTED
		$Throbber/Main.animation = &"spotted"
		$Spot.show()
		$Spot.play()

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
