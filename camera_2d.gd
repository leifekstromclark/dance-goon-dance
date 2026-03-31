extends Camera2D

var velocity: float = 0
@export var smooth_time: float = 0.3
var target: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position.x != target:
		# stole this code from unity engine (smoothdamp)
		var num: float = 2 / smooth_time
		var num2: float = num * delta
		var num3: float = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
		var num4: float = position.x - target
		var num7: float = (velocity + num * num4) * delta
		velocity = (velocity - num * num7) * num3
		var num8: float = target + (num4 + num7) * num3
		if (target - position.x > 0) == (num8 > target):
			velocity = 0
			position.x = target
		position.x = num8
