extends KinematicBody2D

export var run_speed := 300
export var health := 100
onready var animation := $PolicialAnimation
var velocity := Vector2()
enum STATE {ROAMING, CHASING_PLAYER, GOINGTO_LAST_KOWN_PLAYER_POS, DEAD}
var currentState = 0
signal state_changed(currentState)
onready var lineOfSight := $LineOfSight
#  Reference for world navigation tilemap
var levelNavigation : Navigation2D = null
var player = null # Reference to the player
var roamingPoints = [] # List of all roaming points avaliable in the scene

var playerIsInFov = false
var playerIsVisible = false

# 	This can be the players positon, in case of "CHASING_PLAYER" state or it can be
# one of fixed the 'postions' on the map in the "ROAMING" state
var currentPositionToGoTo := Vector2.ZERO

# 	Holds the curerent path that the enemy is walking. Its the path to
# the 'currentPositionToGoTo'
var currentPath = null

#  	This position is used on the state "GOINGTO_LAST_KOWN_PLAYER_POS"
#  when in this state the enemy "roams" to that position and if it doesn't find
# the player the enemy returns to the "ROAMING" state
var lastKnownPlayerPosition := Vector2.ZERO

#	 The current index from the roaming points list that has the point
# the enemy is roaming to
# 	Used to pick a different point to go to
var currentRoamingIndexPoint = 0;


func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if(tree.has_group('LevelNavigation')):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if(tree.has_group('Player')):
		player = tree.get_nodes_in_group("Player")[0]
	if(tree.has_group('RoamingPoint')):
		roamingPoints = tree.get_nodes_in_group("RoamingPoint")
	_updateState(STATE.ROAMING)
	pick_new_random_roaming_point()
	animation.play("walk")
	
	
func _physics_process(_delta):
	if(player && currentState != STATE.DEAD):
		lineOfSight.look_at(player.global_position)
		if(playerIsInFov):
			check_if_player_is_in_visible_range()
		_state_machine()
		#print("PlayerSpoted?: ", (playerIsInFov && playerIsVisible) )
		generate_path_to(currentPositionToGoTo)
		navigate()
		move()
	print("CurrentState: '", 
		STATE.keys()[currentState], 
		"', GoingTo: [",currentRoamingIndexPoint,"] At: ",currentPositionToGoTo)
		
func _state_machine():
	match currentState:
			STATE.ROAMING:
				#If is roaming and sees the player, then start chasing
				if( (playerIsInFov && playerIsVisible) ):
					_updateState(STATE.CHASING_PLAYER)
					_chasePlayer()
				else:
					#Stays in the roaming mode
					#Check if reached current roaming point and if so get a new one
					if(check_if_reached_current_roaming_point()):
						pick_new_random_roaming_point()
			STATE.CHASING_PLAYER:
				#Keep chasing while player is detected
				if( !(playerIsInFov && playerIsVisible) ):
					_updateState(STATE.GOINGTO_LAST_KOWN_PLAYER_POS)
				else:
					_chasePlayer()
			STATE.GOINGTO_LAST_KOWN_PLAYER_POS:
				#	Saw the player again, start chasing!
				if( (playerIsInFov && playerIsVisible) ):
					_updateState(STATE.CHASING_PLAYER)
					_chasePlayer()
				#	Lost vision of player, going to last place player was
				# when last place is found, return to roaming
				elif (check_if_reached_current_roaming_point()):
					_updateState(STATE.ROAMING)
					pick_new_random_roaming_point()
				else:
					pass
			STATE.DEAD:
				# Rip
				pass

func _chasePlayer():
	currentPositionToGoTo = player.global_position
	#look_at(currentPositionToGoTo)
	lastKnownPlayerPosition = currentPositionToGoTo

func _updateState(newState):
	currentState = newState
	emit_signal("state_changed", STATE.keys()[newState])

func compare_position_with_aprox_range(pos1, pos2, tolerance=5):
	var diffX = abs(pos1[0] - pos2[0])
	var diffY = abs(pos1[1] - pos2[1])
	
	if( (diffX > 0 && diffX < tolerance) &&  (diffY > 0 && diffY < tolerance) ):
		return true
	return false

func check_if_reached_current_roaming_point() -> bool:
	if(global_position.distance_to(currentPositionToGoTo) < 5):
		return true
	else:
		return false

#Pega ponto aleatorio no mapa para ir que seja diferente do anterior
func pick_new_random_roaming_point():
	 #print("PontoAtual: [",currentRoamingIndexPoint,"]", currentDestinationPos)
	var newIndexRoamingPoint = randi() % len(roamingPoints)
	while(newIndexRoamingPoint == currentRoamingIndexPoint):
		newIndexRoamingPoint = randi() % len(roamingPoints)
	currentPositionToGoTo = roamingPoints[newIndexRoamingPoint].global_position
	currentRoamingIndexPoint = newIndexRoamingPoint
	
	#print("NovoPonto: [",newIndexRoamingPoint,"]", currentDestinationPos)

func generate_path_to(destination : Vector2):
	if levelNavigation != null and player != null:
		currentPath = levelNavigation.get_simple_path(global_position, destination, false)

func navigate(): #Defines the next position the enemy must moove
	if(currentPath.size() > 1):
		velocity = global_position.direction_to(currentPath[1]) * run_speed
		#if(currentState != STATE.CHASING_PLAYER):
		look_at(currentPath[1])
		#	If the current global position is equal to current path point
		# then pop this point that is already visited
		if(compare_position_with_aprox_range(currentPath[0], global_position, 1)):
			currentPath.pop_front()
	
func die():
	if(currentState != STATE.DEAD):
		var rand = randi() % 2
		match rand:
			0:
				animation.play("die1")
			1:
				animation.play("die2")
		currentState = STATE.DEAD
		emit_signal("state_changed", STATE.keys()[currentState])
		$BodyHitBox/CollisionShape2D.set_deferred("disabled", true)
		$BodyShape.set_deferred("disabled", true)
		$FieldOfView.set_deferred("enabled", false)
		$FieldOfView/FieldOfViewArea.set_deferred("disabled", true)
	

func move():
	move_and_slide(velocity, Vector2.UP)

func check_if_player_is_in_visible_range() -> bool:
	var lineOfSightcolision = lineOfSight.get_collider()
	if(lineOfSightcolision && lineOfSightcolision.is_in_group("Player")):
		playerIsVisible = true
	else: 
		playerIsVisible = false
	return playerIsVisible

#Only colides with "player_weapon" layer
func _on_BodyHitBox_area_entered(_area):
	if(currentState != STATE.DEAD):
		health = health - 50
		if(health <= 0):
			die()

func _on_FieldOfViewArea_body_entered(body):
	if(body.is_in_group("Player")):
		playerIsInFov = true
	
func _on_FieldOfViewArea_body_exited(body):
	if(body.is_in_group("Player")):	
		playerIsInFov = false
