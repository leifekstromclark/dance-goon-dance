extends Scenery

func setup(music_manager: MusicManager) -> void:
	$Skewer.setup(music_manager)
	$Skewer/Throbber.setup(music_manager)
	$Skewer/Throbber2.setup(music_manager)
