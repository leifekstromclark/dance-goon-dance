extends TextureRect

var active: bool = false

@export var default_modulate: Color = Color(1,1,1,1)
@export var beat1_modulate: Color = Color(0,1,1,1)
@export var beat2_modulate: Color = Color(1,0,1,1)
@export var beat3_modulate: Color = Color(1,1,0,1)
@export var beat4_modulate: Color = Color(1,1,1,1)


func setup(music_manager: MusicManager, combo_meter: ComboMeter) -> void:
	combo_meter.change_level.connect(self._on_combo_meter_change_level)
	music_manager.beat.connect(self._on_music_manager_beat)
	active = combo_meter.level > 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_combo_meter_change_level(n: int) -> void:
	active = n > 3

func _on_music_manager_beat(n: int) -> void:
	if active:
		if n % 4 == 0:
			modulate = beat1_modulate
		elif n % 4 == 1:
			modulate = beat2_modulate
		elif n % 4 == 2:
			modulate = beat3_modulate
		else:
			modulate = beat4_modulate
	else:
		modulate = default_modulate
		
