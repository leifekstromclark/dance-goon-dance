extends Control
class_name ComboMeter

var images: Array
var level: int = 2 # 0=D,1=C,2=B,etc.
var progress: int = 0 # percent progress towards next combo level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	images.push_back([preload("res://uiassets/D.png"), preload("res://uiassets/Dshadow.png"), preload("res://uiassets/Dmeter.png")])
	images.push_back([preload("res://uiassets/C.png"), preload("res://uiassets/Cshadow.png"), preload("res://uiassets/Cmeter.png")])
	images.push_back([preload("res://uiassets/B.png"), preload("res://uiassets/Bshadow.png"), preload("res://uiassets/Bmeter.png")])
	images.push_back([preload("res://uiassets/A.png"), preload("res://uiassets/Ashadow.png"), preload("res://uiassets/Ameter.png")])
	images.push_back([preload("res://uiassets/S.png"), preload("res://uiassets/Sshadow.png"), preload("res://uiassets/Smeter.png")])
	$TextureProgressBar.value = progress
	update_textures()

# this needs to be called every time the combo level changes
func update_textures() -> void:
	$TextureProgressBar.texture_progress = images[level][2]
	$Throbber/Letter.texture = images[level][0]
	$Throbber/LetterBG.texture = images[level][1]

# this should be called whenever the player loses the beat
func reset(silent=false) -> void:
	if progress > 0  && !silent:
		$ComboLostSound.play()
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

# add points towards the next combo level. Extra points will overflow to the next. 100 points needed to progress. You can change this value by changing the properties of the TextureProgressBar
func increment(n: int) -> void:
	progress += n
	if progress > 99 && level < images.size() - 1:
		level += 1
		update_textures()
		if level < images.size() - 1:
			progress -= 99
	$TextureProgressBar.value = progress
