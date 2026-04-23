extends Node2D
class_name Game

signal rising_edge # emitted when the beat input window starts
signal falling_edge # emitted when the beat input window ends

var input_error_tolerance: float = 0.2 # in seconds. Change this to be proportional to bpm
var in_input_window: bool # true during the beat input window. false outside of it
var got_input = false # true if input has already been submitted this window. false otherwise

@export var combo_meter: ComboMeter
var background
var scenery: Array
var exit_posns: Array

var left_bound: int
var right_bound: int
var left_camera_bound: int
var right_camera_bound: int
var left_bounded: bool = false
var right_bounded: bool = false
var called_game_over: bool = false
var called_hit_player: bool = false
var combo_protection: bool = true

var level_counter: int = 0

var spawn_pins: Array

var sequence_index: int = 0
var wait_counter: int = 0

# contains all the enemies on the line
var enemies: Array

@warning_ignore("integer_division")
var line_cell_size: int = 388 / 2 # how many pixels is one step
@warning_ignore("integer_division")
var line_offset: int = line_cell_size / 2 # how many pixels is line position 0 offset from pixel position 0
var line_y: int = 980 # the y position of objects on the dance line in pixels

var current_level: Level

# get pixel x-position from line position
func real_xpos(line_pos: int) -> float:
	return line_offset + line_cell_size * line_pos

# can something move into this space?
func is_obstructed(line_pos: int) -> bool:
	if left_bounded && line_pos < left_bound:
		return true
	if right_bounded && line_pos > right_bound:
		return true
	if get_player_line_pos() == line_pos:
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

func get_player_state() -> Player.State:
	return $Player.state

# add a goon to the dance line, all ready to go
func spawn_goon(line_pos: int, goon_type: Level.GoonType) -> void:
	var goon_scene: PackedScene = preload("res://goons/basic_goon.tscn")
	if goon_type == Level.GoonType.RANGED:
		goon_scene = preload("res://goons/ranged_goon.tscn")
	if goon_type == Level.GoonType.DASHING:
		goon_scene = preload("res://goons/dashing_goon.tscn")
	enemies.push_back(goon_scene.instantiate())
	enemies.back().game = self
	enemies.back().line_pos = line_pos
	enemies.back().music_manager = $MusicManager
	enemies.back().face(sign(get_player_line_pos() - line_pos))
	add_child(enemies.back())

# potentially temporary. destroy the goon at position line pos
func hit_goon(line_pos: int) -> void:
	for i in range(enemies.size()): # TS is highkey inefficient but idgaf
		if enemies[i].line_pos == line_pos:
			if enemies[i].damaged:# || combo_meter.level == combo_meter.get_max_level():
				enemies[i].die()
				enemies.remove_at(i)
				combo_meter.increment(50)
			else:
				enemies[i].damage()
			break

func hit_player() -> void:
	if !called_hit_player:
		if combo_meter.level > 0 && combo_meter.level < combo_meter.get_max_level():
			combo_meter.set_level(combo_meter.level - 1)
		elif combo_meter.level == 0:
			game_over()
		combo_meter.reset(true)
		if randf() >= 0.5:
			$GameSound.play_sfx(preload("res://sounds/scratch1.tres"))
		else:
			$GameSound.play_sfx(preload("res://sounds/scratch2.tres"))
		called_hit_player = true


func prepare_level(level: Level) -> void:
	spawn_pins.clear()
	combo_protection = true
	left_bounded = false
	right_bounded = false
	got_input = false
	current_level = level
	sequence_index = 0
	wait_counter = 0
	if background != null:
		background.queue_free()
	for object in scenery:
		object.queue_free()
	scenery.clear()
	for enemy in enemies:
		enemy.queue_free()
	enemies.clear()
	exit_posns.clear()
	background = level.background.instantiate()
	background.setup($MusicManager, $Camera2D/Control/ComboMeter)
	add_child(background)
	$MusicManager.play_song(level.initial_song)
	in_input_window = abs($MusicManager.get_error()) <= input_error_tolerance
	$Player.line_pos = level.player_start_pos
	$Player.position = Vector2(real_xpos($Player.line_pos), line_y)
	$Camera2D.target = real_xpos($Player.line_pos)
	$Camera2D.position.x = real_xpos($Player.line_pos)

func next_level() -> void:
	if level_counter == 0:
		prepare_level(preload("res://levels/banquet_level.tres"))
	else:
		get_tree().change_scene_to_file("res://victory.tscn")
	level_counter += 1

func game_over() -> void:
	if !called_game_over:
		get_tree().change_scene_to_file("res://gameover.tscn")
	called_game_over = true
	#music slowing down effect??

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prepare_level(preload("res://levels/tutorial_level.tres"))


# Called once every frame.
func _process(_delta: float) -> void:
	for exit_pos in exit_posns:
		if get_player_line_pos() == exit_pos:
			next_level()
	
	if !in_input_window && abs($MusicManager.get_error()) <= input_error_tolerance: # rising edge
		in_input_window = true
		called_hit_player = false
		rising_edge.emit()
		
	elif in_input_window && abs($MusicManager.get_error()) > input_error_tolerance: #falling edge
		in_input_window = false
		if !got_input && !combo_protection && (wait_counter <= 0 || current_level.sequence[sequence_index - 1][0] != Level.Event.WAIT_DIALOGUE_NEXT): # missed a beat
			combo_meter.reset()
		got_input = false
		falling_edge.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dgd_pause"): # pause button pressed
		pass
	elif event.is_action_pressed("dgd_dialogue_next"):
		if wait_counter > 0 && current_level.sequence[sequence_index - 1][0] == Level.Event.WAIT_DIALOGUE_NEXT:
			wait_counter = 0
			combo_protection = true
			$Camera2D/Control/Dialogue/NextPrompt.hide()
			$Camera2D/Control/Dialogue.hide()
	elif event.is_action_pressed("dgd_down") || event.is_action_pressed("dgd_up") || event.is_action_pressed("dgd_right") || event.is_action_pressed("dgd_left"):
		combo_protection = false
		if in_input_window && !got_input: # congrats a valid input!
			got_input = true
			if event.is_action_pressed("dgd_left"):
				$Player.move(-1)
				if !left_bounded || get_player_line_pos() > left_bound:
					combo_meter.increment(2)
				set_camera_target(get_player_line_pos())
			elif event.is_action_pressed("dgd_right"):
				if !right_bounded || get_player_line_pos() < right_bound:
					combo_meter.increment(2)
				$Player.move(1)
				set_camera_target(get_player_line_pos())
			elif event.is_action_pressed("dgd_up"):
				$Player.dodge_up()
				combo_meter.increment(2)
			else:
				$Player.dodge_down()
				combo_meter.increment(2)
		else: # womp womp
			combo_meter.reset()
			

func set_camera_target(line_pos: int) -> void:
	if left_bounded && line_pos < left_camera_bound:
		line_pos = left_camera_bound
	if right_bounded && line_pos > right_camera_bound:
		line_pos = right_camera_bound
	$Camera2D.target = real_xpos(line_pos)

func _on_music_manager_beat(n: int) -> void:
	if wait_counter > 0:
		var last_event = current_level.sequence[sequence_index - 1]
		if last_event[0] == Level.Event.WAIT_BEATS:
			wait_counter -= 1
		elif last_event[0] == Level.Event.WAIT_KILL && enemies.is_empty():
			wait_counter = 0
		elif last_event[0] == Level.Event.ALIGN_MEASURE && n % 4 == 0:
			wait_counter = 0
	
	while wait_counter <= 0 && sequence_index < current_level.sequence.size():
		var event = current_level.sequence[sequence_index]
		sequence_index += 1
		if event[0] == Level.Event.DIALOGUE:
			$Camera2D/Control/Dialogue.display_message(event[1], event[2])
		elif event[0] == Level.Event.HIDE_DIALOGUE:
			$Camera2D/Control/Dialogue.hide()
		elif event[0] == Level.Event.SPAWN:
			for spawn in event[3]:
				var spawn_pos = spawn[1] + spawn_pins[event[1]]
				if !is_obstructed(spawn_pos):
					spawn_goon(spawn_pos, spawn[0])
				elif event[2]:
					for i in range(1,10): # magic number
						spawn_pos += i * pow(-1, i)
						if !is_obstructed(spawn_pos):
							spawn_goon(spawn_pos, spawn[0])
							break
		elif event[0] == Level.Event.WAIT_BEATS:
			wait_counter = event[1]
		elif event[0] == Level.Event.QUEUE_SONG:
			$MusicManager.queue_song(event[1])
		elif event[0] == Level.Event.WAIT_KILL && !enemies.is_empty():
			wait_counter = 1
		elif event[0] == Level.Event.ALIGN_MEASURE && n % 4 != 0:
			wait_counter = 1
		elif event[0] == Level.Event.SET_BOUND: # just don't set this too close to the player and we're probably fine
			if event[1]:
				right_bounded = true
				right_bound = get_player_line_pos() + event[2]
				right_camera_bound = get_player_line_pos() + event[3]
			else:
				left_bounded = true
				left_bound = get_player_line_pos() + event[2]
				left_camera_bound = get_player_line_pos() + event[3]
		elif event[0] == Level.Event.REMOVE_BOUND:
			if event[1]:
				right_bounded = false
			else:
				left_bounded = false
		elif event[0] == Level.Event.ADD_EXIT:
			exit_posns.push_back(get_player_line_pos() + event[1])
		elif event[0] == Level.Event.WIN:
			next_level()
		elif event[0] == Level.Event.ADD_SCENERY:
			var object = event[2].instantiate()
			object.position.x = real_xpos(get_player_line_pos() + event[1])
			object.setup($MusicManager)
			scenery.push_back(object)
			add_child(object)
		elif event[0] == Level.Event.JUMP:
			sequence_index += event[1] - 1
		elif event[0] == Level.Event.WAIT_DIALOGUE_NEXT:
			wait_counter = 1
			$Camera2D/Control/Dialogue/NextPrompt.show()
		elif event[0] == Level.Event.PUSH_PIN:
			spawn_pins.push_back(get_player_line_pos())
		elif event[0] == Level.Event.POP_PIN:
			spawn_pins.pop_back()
