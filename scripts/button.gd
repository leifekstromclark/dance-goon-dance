extends Button

var label_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_pos = $Label.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_button_down():
	$Label.position -= Vector2(25, 25)
	$AudioStreamPlayer.play()

func _on_button_up():
	$Label.position = label_pos
