extends Node2D
class_name Game

signal rising_edge
signal falling_edge

var input_error_tolerance = 0.2 # in seconds. Change this to be proportional to bpm
var in_input_window
var got_input = false

@export var tutorial_4: AudioWrapper
@export var combo_meter: ComboMeter

#TO DO: ADD GROOVE METER LABEL AND CAPTION TO COMBO METER
#       ADD COMBO PROTECTION UNTIL FIRST MOVE OF THE GAME

enum LevelEvent {SPAWN, WAIT_BEATS, WAIT_KILL, SOUND, DIALOGUE}

var enemies: Array

var line_cell_size = 120
var line_offset = 60
var line_y = 650

var basic_goon_scene: PackedScene

func real_xpos(line_pos: int) -> float:
	return line_offset + line_cell_size * line_pos

func is_obstructed(line_pos: int) -> bool:
	if $Player.line_pos == line_pos:
		return true
	for enemy in enemies:
		if enemy.line_pos == line_pos:
			return true
	# add condition for walls and closed doors
	return false

func is_attackable(line_pos: int) -> bool:
	for enemy in enemies: # TS is highkey inefficient but idgaf
		if enemy.line_pos == line_pos:
			return true
	return false

func get_player_line_pos() -> int:
	return $Player.line_pos

func spawn_basic_goon(line_pos: int) -> void:
	enemies.push_back(basic_goon_scene.instantiate())
	enemies.back().game = self
	enemies.back().line_pos = line_pos
	add_child(enemies.back())

func player_attack(line_pos: int) -> void: # temporary for testing
	print(enemies)
	for i in range(enemies.size()):
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
	spawn_basic_goon(3)
	spawn_basic_goon(-3)
	spawn_basic_goon(6)
	spawn_basic_goon(-6)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !in_input_window && abs($MusicManager.get_error()) <= input_error_tolerance: # rising edge
		in_input_window = true
		rising_edge.emit()
		
	elif in_input_window && abs($MusicManager.get_error()) > input_error_tolerance: #falling edge
		in_input_window = false
		# RESOLVE enemy actions
		if !got_input: # missed a beat
			combo_meter.reset()
		got_input = false
		falling_edge.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dgd_pause"):
		pass
	elif event.is_action_pressed("dgd_down") || event.is_action_pressed("dgd_up") || event.is_action_pressed("dgd_right") || event.is_action_pressed("dgd_left"):
		if in_input_window && !got_input:
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
		else:
			combo_meter.reset()
