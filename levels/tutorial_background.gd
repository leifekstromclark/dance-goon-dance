extends Node2D
class_name TutorialBackground


func setup(music_manager: MusicManager, combo_meter: ComboMeter) -> void:
	$Back/Throbber.setup(music_manager)
	$Back/Throbber2.setup(music_manager)
	$Back/Skewer.setup(music_manager)
	$Far/Skewer.setup(music_manager)
	$LessFar/Skewer.setup(music_manager)
	$MiddleLamps/Throbber.setup(music_manager)
	$FrontLamps/Throbber.setup(music_manager)
	$MiddleLamps/Throbber/Glow.setup(music_manager, combo_meter)
	$FrontLamps/Throbber/Glow.setup(music_manager, combo_meter)
