extends Node2D

var timer_max: float = 0.5
var timer: float = timer_max

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	self.modulate = Color(1, 1, 1, timer / timer_max)
	if timer <= 0:
		self.queue_free()

func set_texture(texture: Texture):
	$Sprite2D.texture = texture
