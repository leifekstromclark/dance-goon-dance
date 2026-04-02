extends Node2D
class_name BasicGoon

var line_pos = 0
var game: Game

@export var cooldown: int = 0

var playerDistance: int = 0
@onready var player = get_tree().get_root().get_node("Game").get_node("Player")
@onready var music = get_tree().get_root().get_node("Game").get_node("MusicManager")
var telegraphed: bool = false

# what action is the player currently doing? often read by other scripts
enum enemyState {SPOTTED, TELEGRAPH, ATTACKHIGH, ATTACKLOW, NEUTRAL}
var state: enemyState = enemyState.NEUTRAL
var reset: bool = false
var actionDone: bool = false # determines if action has been done this beat input window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(game.real_xpos(line_pos), game.line_y)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	playerDistance = game.distance_check(line_pos)
	if reset == true and actionDone == true:
		if playerDistance == 2:
			state = enemyState.SPOTTED
			$AnimatedSprite2D.animation = &"Spotted"
		if playerDistance == 1:
			state = enemyState.TELEGRAPH
			$AnimatedSprite2D.animation = &"Telegraph"
			telegraphed = true
			print("not attacking")
		if playerDistance == 1 and telegraphed == true and cooldown <= 0:
			print("imma attack")
			if randf_range(0, 10) > 5:
				state = enemyState.ATTACKHIGH
				$AnimatedSprite2D.animation = &"AttackHigh"
			else:
				state = enemyState.ATTACKLOW
				$AnimatedSprite2D.animation = &"AttackLow"
				cooldown = 1
				telegraphed = false
		else:
			$AnimatedSprite2D.animation = &"Idle"
	
		if state == enemyState.ATTACKHIGH and player.duck == false:
			get_tree().reload_current_scene()
		elif state == enemyState.ATTACKLOW and player.jump == false:
			get_tree().reload_current_scene()
		reset = false
		actionDone = true
	
	# trying to figure out how the heck you can make it so that acts every beat but signal won't work with instianated from music_manager for some annoying reason
	if game.in_input_window == true:
		reset = true
		actionDone = false
