extends AudioStreamPlayer

func play_note(sound: SFXWrapper, target_note: int, start: float = 0) -> void:
	stream = sound.stream
	var semi_tones: float = target_note - sound.note
	pitch_scale = pow(2, semi_tones / 12.0)
	volume_db = linear_to_db(sound.volume_scale)
	play(start)

func play_sfx(sound: SFXWrapper, start: float = 0) -> void:
	stream = sound.stream
	pitch_scale = 1 + randf() * sound.pitch_variation * 2 - sound.pitch_variation
	volume_db = linear_to_db(sound.volume_scale + randf() * sound.volume_variation * 2 - sound.volume_variation)
	play(start)
