extends Node2D
class_name BanquetBackground


func setup(music_manager: MusicManager, combo_meter: ComboMeter) -> void:
	$Back/Throbber.setup(music_manager)
	$Back/Throbber2.setup(music_manager)
	$Back/Skewer.setup(music_manager)
	$Far/Skewer.setup(music_manager)
	$LessFar/Skewer.setup(music_manager)
	$BackWall/Throbber.setup(music_manager)
	$Lights/Throbber.setup(music_manager)
	$Lights/Throbber2.setup(music_manager)
	$Lights/Throbber/Glow.setup(music_manager, combo_meter)
	$Lights/Throbber2/Glow.setup(music_manager, combo_meter)
	$FarTables/Skewer.setup(music_manager)
	$Workers2/Throbber.setup(music_manager)
	$Workers2/Throbber2.setup(music_manager)
	$Workers1/Throbber.setup(music_manager)
	$Workers1/Throbber2.setup(music_manager)
	$NearTables/Skewer.setup(music_manager)
	
