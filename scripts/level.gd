extends Resource
class_name Level

enum Event {SPAWN, PUSH_PIN, POP_PIN, WAIT_BEATS, WAIT_KILL, QUEUE_SONG, DIALOGUE, ALIGN_MEASURE, SET_BOUND, REMOVE_BOUND, ADD_EXIT, WIN, ADD_SCENERY, JUMP, HIDE_DIALOGUE, WAIT_DIALOGUE_NEXT}
enum GoonType {BASIC, RANGED, DASHING}

@export var sequence: Array
@export var initial_sequence: Array
@export var initial_song: MusicWrapper
@export var background: PackedScene
@export var player_start_pos: int
@export var line_y: int
