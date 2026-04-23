extends Label

var timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		timer -= delta
		if timer <= 0:
			hide()

func fire() -> void:
	show()
	var timer = 0.3
