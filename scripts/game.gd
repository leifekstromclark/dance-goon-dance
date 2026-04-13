extends Node2D
class_name Game

signal rising_edge # emitted when the beat input window starts
signal falling_edge # emitted when the beat input window ends

var input_error_tolerance: float = 0.2 # in seconds. Change this to be proportional to bpm
var in_input_window: bool # true during the beat input window. false outside of it
var got_input = false # true if input has already been submitted this window. false otherwise

@export var tutorial_4: AudioWrapper
@export var combo_meter: ComboMeter

#TO DO: ADD GROOVE METER LABEL AND CAPTION TO COMBO METER
#       ADD COMBO PROTECTION UNTIL FIRST MOVE OF THE GAME


# These are gonna be used for level sequencing. Won't be needed for demo hopefully.
enum LevelEvent {SPAWN, WAIT_BEATS, WAIT_KILL, SOUND, DIALOGUE}

# contains all the enemies on the line
var enemies: Array

var line_cell_size = 388 / 2 # how many pixels is one step
var line_offset = line_cell_size / 2 # how many pixels is line position 0 offset from pixel position 0
var line_y = 980 # the y position of objects on the dance line in pixels

var basic_goon_scene: PackedScene # prefab for instantiating basic goons

var damage_sound: AudioStream

# get pixel x-position from line position
func real_xpos(line_pos: int) -> float:
	return line_offset + line_cell_size * line_pos

# can something move into this space?
func is_obstructed(line_pos: int) -> bool:
	if $Player.line_pos == line_pos:
		return true
	for enemy in enemies: # TS is highkey inefficient but idgaf
		if enemy.line_pos == line_pos:
			return true
	# add condition for walls and closed doors
	return false

# is there an enemy for the player to attack on this space?
func is_attackable(line_pos: int) -> bool:
	for enemy in enemies: # TS is highkey inefficient but idgaf
		if enemy.line_pos == line_pos:
			return true
	return false

func get_player_line_pos() -> int:
	return $Player.line_pos

func get_player_state() -> Player.PlayerState:
	return $Player.state

# add a goon to the dance line, all ready to go
func spawn_basic_goon(line_pos: int) -> void:
	enemies.push_back(basic_goon_scene.instantiate())
	enemies.back().game = self
	enemies.back().line_pos = line_pos
	enemies.back().music_manager = $MusicManager
	add_child(enemies.back())

# potentially temporary. destroy the goon at position line pos
func hit_goon(line_pos: int) -> void:
	for i in range(enemies.size()): # TS is highkey inefficient but idgaf
		if enemies[i].line_pos == line_pos:
			if enemies[i].damaged || combo_meter.level == combo_meter.get_max_level():
				enemies[i].die()
				enemies.remove_at(i)
				combo_meter.increment(50)
			else:
				enemies[i].damage()
			break

func hit_player() -> void:
	if combo_meter.level > 0 && combo_meter.level < combo_meter.get_max_level():
		combo_meter.set_level(combo_meter.level - 1)
	elif combo_meter.level == 0:
		get_tree().change_scene_to_file("res://title.tscn")
	combo_meter.reset(true)
	$GameSound.stream = damage_sound
	$GameSound.play()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MusicManager.play_song(tutorial_4)
	in_input_window = abs($MusicManager.get_error()) <= input_error_tolerance
	$Camera2D.target = real_xpos($Player.line_pos)
	$Camera2D.position.x = real_xpos($Player.line_pos)
	basic_goon_scene = preload("res://basic_goon.tscn")
	damage_sound = preload("res://sounds/minecraftoof.mp3")
	spawn_basic_goon(3)
	spawn_basic_goon(6)
	spawn_basic_goon(-3)
	spawn_basic_goon(-6)


# Called once every frame.
func _process(delta: float) -> void:
	
	if !in_input_window && abs($MusicManager.get_error()) <= input_error_tolerance: # rising edge
		in_input_window = true
		rising_edge.emit()
		
	elif in_input_window && abs($MusicManager.get_error()) > input_error_tolerance: #falling edge
		in_input_window = false
		if !got_input: # missed a beat
			combo_meter.reset()
		got_input = false
		falling_edge.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dgd_pause"): # pause button pressed
		pass
	elif event.is_action_pressed("dgd_down") || event.is_action_pressed("dgd_up") || event.is_action_pressed("dgd_right") || event.is_action_pressed("dgd_left"):
		if in_input_window && !got_input: # congrats a valid input!
			got_input = true
			combo_meter.increment(5)
			if event.is_action_pressed("dgd_left"):
				$Player.move(-1)
				$Camera2D.target = real_xpos($Player.line_pos)
			elif event.is_action_pressed("dgd_right"):
				$Player.move(1)
				$Camera2D.target = real_xpos($Player.line_pos)
			elif event.is_action_pressed("dgd_up"):
				$Player.dodge_up()
			else:
				$Player.dodge_down()
		else: # womp womp
			combo_meter.reset()


func _on_music_manager_beat(n: int) -> void:
	if n % 8 == 7:
		var spawn_pos_1 = get_player_line_pos() - 6 + randi() % 3
		var spawn_pos_2 = get_player_line_pos() + 6 - randi() % 3
		if !is_obstructed(spawn_pos_1):
			spawn_basic_goon(spawn_pos_1)
		if !is_obstructed(spawn_pos_2):
			spawn_basic_goon(spawn_pos_2)
