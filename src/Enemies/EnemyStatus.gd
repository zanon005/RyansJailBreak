extends Sprite

var roaming_icon = null
var searching_icon = null
var chasing_icon = null
var start_position = Vector2()

func _ready():
	roaming_icon = load("res://Sprites/Icons/RoamingIcon.png")
	searching_icon = load("res://Sprites/Icons/YellowQuestionMark.png")
	chasing_icon = load("res://Sprites/Icons/RedExclamationMark.png")

func _on_Policial_state_changed(currentState):
	print("STATE CHANGED!", currentState)
	match(currentState): 
		'ROAMING':
			texture = roaming_icon
		'CHASING_PLAYER':
			texture = chasing_icon
		'GOINGTO_LAST_KOWN_PLAYER_POS':
			texture = searching_icon
		'DEAD':
			texture = null
