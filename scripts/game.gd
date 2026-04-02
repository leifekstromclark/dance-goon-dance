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

var line_cell_size = 120 # how many pixels is one step
var line_offset = 60 # how many pixels is line position 0 offset from pixel position 0
var line_y = 650 # the y position of objects on the dance line in pixels

var basic_goon_scene: PackedScene # prefab for instantiating basic goons

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

# add a goon to the dance line, all ready to go
func spawn_basic_goon(line_pos: int) -> void:
	enemies.push_back(basic_goon_scene.instantiate())	
	enemies.back().game = self
	enemies.back().line_pos = line_pos
	add_child(enemies.back())
	
# get distance from player in line_pos
func distance_check(line_pos: int) -> int:
	return abs($Player.line_pos - line_pos)
	

# potentially temporary. destroy the goon at position line pos
func player_attack(line_pos: int) -> void:
	print(enemies)
	for i in range(enemies.size()): # TS is highkey inefficient but idgaf
		if enemies[i].line_pos == line_pos:
			enemies[i].queue_free()
			enemies.remove_at(i)
			break
	combo_meter.increment(50)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MusicManager.play_song(tutorial_4)
	in_input_window = abs($MusicManager.get_error()) <= input_error_tolerance
	$Camera2D.target = real_xpos($Player.line_pos)
	$Camera2D.position.x = real_xpos($Player.line_pos)
	basic_goon_scene = preload("res://basic_goon.tscn")
	#spawn_basic_goon(3)
	#spawn_basic_goon(-3)
	spawn_basic_goon(6)
	#spawn_basic_goon(-6)


# Called once every frame.
func _process(delta: float) -> void:
	
	if !in_input_window && abs($MusicManager.get_error()) <= input_error_tolerance: # rising edge
		in_input_window = true
		rising_edge.emit()
		
	elif in_input_window && abs($MusicManager.get_error()) > input_error_tolerance: #falling edge
		in_input_window = false
		
		# RESOLVE the repercussions of enemy actions here
		# (player should have done their input by now)
		# some animations and sound effects of the enemy actions can and should be played directly on beat - probably from the enemy's script
		
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
