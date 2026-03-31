extends Control
class_name ComboMeter

var images: Array
var level: int = 0
var progress: int = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	images.push_back([preload("res://uiassets/D.png"), preload("res://uiassets/Dshadow.png"), preload("res://uiassets/Dmeter.png")])
	images.push_back([preload("res://uiassets/C.png"), preload("res://uiassets/Cshadow.png"), preload("res://uiassets/Cmeter.png")])
	images.push_back([preload("res://uiassets/B.png"), preload("res://uiassets/Bshadow.png"), preload("res://uiassets/Bmeter.png")])
	images.push_back([preload("res://uiassets/A.png"), preload("res://uiassets/Ashadow.png"), preload("res://uiassets/Ameter.png")])
	images.push_back([preload("res://uiassets/S.png"), preload("res://uiassets/Sshadow.png"), preload("res://uiassets/Smeter.png")])
	$TextureProgressBar.value = progress
	update_textures()
	
func update_textures() -> void:
	$TextureProgressBar.texture_progress = images[level][2]
	$Throbber/Letter.texture = images[level][0]
	$Throbber/LetterBG.texture = images[level][1]
	
func reset() -> void:
	if progress > 0:
		$ComboLostSound.play()
	progress = 0
	if level == images.size() - 1:
		set_level(images.size() - 2)
	$TextureProgressBar.value = progress
	
func set_level(new_level: int) -> void:
	level = new_level
	update_textures()
	
func increment(n: int) -> void:
	progress += n
	if progress > 99 && level < images.size() - 1:
		level += 1
		update_textures()
		if level < images.size() - 1:
			progress -= 99
	$TextureProgressBar.value = progress
