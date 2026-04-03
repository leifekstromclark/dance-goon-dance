extends Camera2D

var velocity: float = 0
@export var smooth_time: float = 0.3
var target: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = position.x

# Called once every frame.
func _process(delta: float) -> void:
	# Follow the player
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

# We wont ever need to change anything in this script.
# The one last camera feature I want to add is to make the camera stop moving at the edge of the map
# This can be accomplished simply by clamping the target variable when setting it in the game controller
