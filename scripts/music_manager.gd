extends Node
class_name MusicManager

# This object plays music on loop and tracks latency adjusted time and beat

signal beat(n: int) # emitted every beat. first beat is n=0

var time_begin: int # the time the music started (in microseconds) obtained from OS
var time_delay: float # approximate audio delay (in seconds)
var start_position = 0 # the time in the audio file at which the music started (in seconds)

var beat_num: int # index of current beat starting at 0
var first_beat # true before first beat. false after

var current_song: MusicWrapper
var next_song: MusicWrapper
var beat_length: float # how long is 1 beat (in seconds)
var beat_start: float # at what time in the audio file was the last beat (in seconds)
var resync_threshold: float = 0.05


# Returns the latency adjusted time in seconds since the music started
func get_time() -> float: # time should be calculated by (_input, _process, _pause, etc) at any call
	return max(0, (Time.get_ticks_usec() - time_begin) / 1000000.0 - time_delay)

# Returns the difference between the current (latency adjusted) time and the time of the closest beat
func get_error() -> float:
	var error =  get_time() - beat_start
	if error > beat_length / 2:
		error -= beat_length
	return error

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Play the stream contained in the "song" audio wrapper on loop starting at the beginning
func play_song(song: MusicWrapper) -> void:
	current_song = song
	next_song = song
	beat_length = 60.0 / song.bpm
	beat_start = song.first_beat
	start_position = 0
	beat_num = 0
	first_beat = true
	$AudioStreamPlayer.stream = song.stream
	resume()

func queue_song(song: MusicWrapper) -> void:
	next_song = song

# Start playing the current song from wherever it left off
func resume() -> void:
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	$AudioStreamPlayer.play(start_position)

# Pause the current song and save the time for resume
func pause() -> void:
	start_position = $AudioStreamPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	beat_start -= start_position
	$AudioStreamPlayer.stop()

func resync() -> void: # I don't think this currently works
	var hearing = $AudioStreamPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	print(get_time())
	print(hearing)
	if abs(get_time() - hearing) > resync_threshold:
		print("resync")
		time_begin = Time.get_ticks_usec()
		time_delay = 0
		beat_num = floor((hearing - current_song.first_beat) / beat_length)
		beat_start = current_song.first_beat + beat_num * beat_length - hearing
		$Resyncing.fire()


# Called once every frame.
func _process(_delta: float) -> void:
	if $AudioStreamPlayer.playing:
		var hearing = get_time()
		# Check if the (latency adjusted) music has reached the next beat and emit a signal
		if first_beat && hearing >= beat_start:
			beat.emit(beat_num)
			first_beat = false
		if hearing - beat_start >= beat_length:
			beat_start += beat_length # increment to the next beat exactly
			beat_num += 1
			beat.emit(beat_num)

# seamlessly loop from beginning if the song is finished
func _on_audio_stream_player_finished() -> void:
	current_song = next_song
	play_song(current_song)
