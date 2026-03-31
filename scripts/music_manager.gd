extends Node
class_name MusicManager

signal beat(n: int)

# all time variables are in units of seconds

var time_begin
var time_delay
var start_position = 0
var beat_length
var beat_start
var beat_num
var current_song
var first_beat


func get_time() -> float: # time should be calculated by (_input, _process, _pause, etc) at any call
	return max(0, (Time.get_ticks_usec() - time_begin) / 1000000.0 - time_delay)


func get_error() -> float:
	var error =  get_time() - beat_start
	if error > beat_length / 2:
		error -= beat_length
	return error


func _ready() -> void:
	pass

func play_song(song: AudioWrapper) -> void:
	current_song = song
	beat_length = 60.0 / song.bpm
	beat_start = song.first_beat
	start_position = 0
	beat_num = 0
	first_beat = true
	$AudioStreamPlayer.stream = song.stream
	resume()


func resume() -> void:
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	$AudioStreamPlayer.play(start_position)

func pause() -> void:
	beat_start -= get_time()
	start_position += get_time()
	$AudioStreamPlayer.stop()


func _process(_delta: float) -> void:
	if $AudioStreamPlayer.playing:
		var time = get_time()
		if first_beat && time >= beat_start:
			beat.emit(beat_num)
			first_beat = false
		if time - beat_start >= beat_length:
			beat_start += beat_length # increment to the next beat exactly
			beat_num += 1
			beat.emit(beat_num)

func _on_audio_stream_player_finished() -> void:
	start_position = 0
	beat_num = 0
	first_beat = true
	beat_start = current_song.first_beat
	resume()
