extends KinematicBody2D

export var run_speed := 300
export var health := 100
onready var animation := $PolicialAnimation
var velocity := Vector2()

var playerIsSpoted : bool = false
var lastSpotedPlayerPos := Vector2.ZERO

var currentDestinationPos := Vector2.ZERO
var reachedCurrentDestinationPos := false

enum STATE {ROAMING, CHASING_PLAYER, GOINGTO_LAST_KOWN_PLAYER_POS, DEAD}
var currentState = STATE.ROAMING
var currentRoamingIndexPoint = 0;

var roamingPoints = []
var path : Array = [] # Array com a lista de pontos para se mover
var levelNavigation : Navigation2D = null
var player = null
onready var lineOfSight := $LineOfSight

func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if(tree.has_group('LevelNavigation')):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if(tree.has_group('Player')):
		player = tree.get_nodes_in_group("Player")[0]
	roamingPoints = tree.get_nodes_in_group("RoamingPoint")
	pick_random_roaming_point()
	animation.play("walk")
	
	
func _physics_process(delta):
	if(player && currentState != STATE.DEAD):
		lineOfSight.look_at(player.global_position)
		_state_machine()
		check_if_player_is_in_visible_range()
		look_at(currentDestinationPos)
		generate_path_to(currentDestinationPos)
		navigate()
		move()
	print("CurrentState: '", STATE.keys()[currentState], "', GoingTo: [",currentRoamingIndexPoint,"] At: ",currentDestinationPos)
		
func _state_machine():
	match currentState:
			STATE.ROAMING:
				if(playerIsSpoted):
					currentState = STATE.CHASING_PLAYER
				elif(check_if_reached_current_destination()):
					pick_random_roaming_point()
			STATE.CHASING_PLAYER:
				if(!playerIsSpoted):
					currentState = STATE.GOINGTO_LAST_KOWN_PLAYER_POS
			STATE.GOINGTO_LAST_KOWN_PLAYER_POS:
				if(playerIsSpoted):
					currentState = STATE.CHASING_PLAYER
				elif(check_if_reached_current_destination()):
					currentState = STATE.ROAMING
			STATE.DEAD:
				pass

func check_if_reached_current_destination() -> bool:
	var aproxEqualX = int(global_position[0]) == int(currentDestinationPos[0])
	var aproxEqualY = int(global_position[1]) == int(currentDestinationPos[1])
	reachedCurrentDestinationPos = aproxEqualX && aproxEqualY
	return reachedCurrentDestinationPos

func check_if_player_is_in_visible_range() -> bool:
	var lineOfSightcolision = lineOfSight.get_collider()
	if(lineOfSightcolision && lineOfSightcolision.is_in_group("Player")):
		playerIsSpoted = true
		currentDestinationPos = player.global_position
		lastSpotedPlayerPos = player.global_position
		reachedCurrentDestinationPos = false
		return true
	playerIsSpoted = false
	return false

#Pega ponto aleatorio no mapa para ir que seja diferente do anterior
func pick_random_roaming_point():
	var indexRoamingPoint = randi() % len(roamingPoints)
	while(indexRoamingPoint == currentRoamingIndexPoint):
		indexRoamingPoint = randi() % len(roamingPoints)
	currentDestinationPos = roamingPoints[indexRoamingPoint].global_position
	print('Rand: ',currentRoamingIndexPoint, indexRoamingPoint)
	currentRoamingIndexPoint = indexRoamingPoint
	reachedCurrentDestinationPos = false

func navigate(): #Defines the next position the enemy must moove
	if(path.size() > 1):
		velocity = global_position.direction_to(path[1]) * run_speed
		#	If the current global position is equal to current path point
		# then pop this point that is already visited
		if(global_position == path[0]):
			path.pop_front()
	
func generate_path_to(destination : Vector2):
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, destination, false)

func die():
	if(currentState != STATE.DEAD):
		var rand = randi() % 2
		match rand:
			0:
				animation.play("die1")
			1:
				animation.play("die2")
		currentState = STATE.DEAD

func move():
	move_and_slide(velocity, Vector2.UP)


#Only colides with "player_weapon" layer
func _on_BodyHitBox_area_entered(area):
	if(currentState != STATE.DEAD):
		health = health - 50
		if(health <= 0):
			die()
	
