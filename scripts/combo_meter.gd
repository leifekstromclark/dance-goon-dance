extends Control
class_name ComboMeter

signal change_level(n: int)

var images: Array
var combo_remarks: Array
var level: int = 2 # 0=D,1=C,2=B,etc.
var progress: int = 0 # percent progress towards next combo level
@export var losing_groove: Control
@export var music_manager: MusicManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	images.push_back([preload("res://uiassets/D.png"), preload("res://uiassets/Dshadow.png"), preload("res://uiassets/Dmeter.png")])
	images.push_back([preload("res://uiassets/C.png"), preload("res://uiassets/Cshadow.png"), preload("res://uiassets/Cmeter.png")])
	images.push_back([preload("res://uiassets/B.png"), preload("res://uiassets/Bshadow.png"), preload("res://uiassets/Bmeter.png")])
	images.push_back([preload("res://uiassets/A.png"), preload("res://uiassets/Ashadow.png"), preload("res://uiassets/Ameter.png")])
	images.push_back([preload("res://uiassets/S.png"), preload("res://uiassets/Sshadow.png"), preload("res://uiassets/Smeter.png")])
	$TextureProgressBar.value = progress
	combo_remarks.push_back("What a goon...")
	combo_remarks.push_back("Gettin' the Groove")
	combo_remarks.push_back("Groove, Goon! Groove!")
	combo_remarks.push_back("NO MORE GOONING!")
	combo_remarks.push_back("The Holy Groover")
	update_textures()

# this needs to be called every time the combo level changes
func update_textures() -> void:
	$TextureProgressBar.texture_progress = images[level][2]
	$Throbber/Letter.texture = images[level][0]
	$Throbber/LetterBG.texture = images[level][1]
	$Throbber2/ComboRemark.text = combo_remarks[level]

# this should be called whenever the player loses the beat
func reset(silent=false) -> void:
	if progress > 0  && !silent:
		$SFXPlayer.play_sfx(preload("res://sounds/woosh.tres"))
		$MissIndicator.fire()
	progress = 0
	if level == images.size() - 1:
		set_level(images.size() - 2)
	$TextureProgressBar.value = progress

func get_max_level() -> int:
	return images.size() - 1

# manually set the combo level
func set_level(new_level: int) -> void:
	level = new_level
	update_textures()
	if level == 0:
		losing_groove.show()
	else:
		losing_groove.hide()
	change_level.emit(level)

# add points towards the next combo level. Extra points will overflow to the next. 100 points needed to progress. You can change this value by changing the properties of the TextureProgressBar
func increment(n: int) -> void:
	progress += n	
	if progress > 99 && level < images.size() - 1:
		var arpeggio_offsets = [0, 3, 7, 12]
		if music_manager.current_song.major:
			arpeggio_offsets[1] = 4
		$SFXPlayer.play_note(preload("res://sounds/brass_hit.tres"), music_manager.current_song.key + arpeggio_offsets[level % 4]) # TEMPORARY_HACK
		set_level(level + 1)
		if level < images.size() - 1:
			progress -= 100
	$TextureProgressBar.value = progress
