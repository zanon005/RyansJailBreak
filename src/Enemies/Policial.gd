extends KinematicBody2D

export var run_speed := 150
export var health := 100
onready var animation := $PolicialAnimation
onready var bodyColision := $BodyShape
onready var bodyHitbox := $BodyHitBox/CollisionShape2D
var velocity := Vector2()
signal state_changed(currentState)

var playerIsSpoted : bool = false
var lastSpotedPlayerPos := Vector2.ZERO

var currentDestinationPos := Vector2.ZERO
var reachedCurrentDestinationPos := false

enum STATE {ROAMING, CHASING_PLAYER, GOINGTO_LAST_KOWN_PLAYER_POS, DEAD}
var currentState = 0
var currentRoamingIndexPoint = 0;

var roamingPoints = []
var currentPath : Array = [] # Array com a lista de pontos para se mover
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
	currentState = STATE.ROAMING
	emit_signal("state_changed", currentState)
	roamingPoints = tree.get_nodes_in_group("RoamingPoint")
	pick_random_roaming_point()
	animation.play("walk")
	
	
func _physics_process(_delta):
	if(player && currentState != STATE.DEAD):
		lineOfSight.look_at(player.global_position)
		check_if_player_is_in_visible_range()
		_state_machine()
		generate_path_to(currentDestinationPos)
		navigate()
		move()
	#print("CurrentState: '", 
	#	STATE.keys()[currentState], 
	#	"', GoingTo: [",currentRoamingIndexPoint,"] At: ",currentDestinationPos)
		
func _state_machine():
	match currentState:
			STATE.ROAMING:
				if(playerIsSpoted):
					currentState = STATE.CHASING_PLAYER
					emit_signal("state_changed", STATE.keys()[currentState])
				elif(check_if_reached_current_destination()):
					pick_random_roaming_point()
			STATE.CHASING_PLAYER:
				if(!playerIsSpoted):
					currentState = STATE.GOINGTO_LAST_KOWN_PLAYER_POS
					emit_signal("state_changed", STATE.keys()[currentState])
			STATE.GOINGTO_LAST_KOWN_PLAYER_POS:
				if(playerIsSpoted):
					currentState = STATE.CHASING_PLAYER
					emit_signal("state_changed", STATE.keys()[currentState])
				elif(check_if_reached_current_destination()):
					currentState = STATE.ROAMING
					emit_signal("state_changed", STATE.keys()[currentState])
			STATE.DEAD:
				pass

func compare_position_with_aprox_range(pos1, pos2, tolerance=5):
	var diffX = abs(pos1[0] - pos2[0])
	var diffY = abs(pos1[1] - pos2[1])
	
	if( (diffX > 0 && diffX < tolerance) &&  (diffY > 0 && diffY < tolerance) ):
		return true
	return false

func check_if_reached_current_destination() -> bool:
	reachedCurrentDestinationPos = compare_position_with_aprox_range(global_position, currentDestinationPos)
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
	 #print("PontoAtual: [",currentRoamingIndexPoint,"]", currentDestinationPos)
	
	var newIndexRoamingPoint = randi() % len(roamingPoints)
	while(newIndexRoamingPoint == currentRoamingIndexPoint):
		newIndexRoamingPoint = randi() % len(roamingPoints)
	currentDestinationPos = roamingPoints[newIndexRoamingPoint].global_position
	currentRoamingIndexPoint = newIndexRoamingPoint
	
	#print("NovoPonto: [",newIndexRoamingPoint,"]", currentDestinationPos)
	reachedCurrentDestinationPos = false

func navigate(): #Defines the next position the enemy must moove
	if(currentPath.size() > 1):
		velocity = global_position.direction_to(currentPath[1]) * run_speed
		look_at(currentPath[1])
		#	If the current global position is equal to current path point
		# then pop this point that is already visited
		if(compare_position_with_aprox_range(currentPath[0], global_position, 1)):
			currentPath.pop_front()
	
func generate_path_to(destination : Vector2):
	if levelNavigation != null and player != null:
		currentPath = levelNavigation.get_simple_path(global_position, destination, false)

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
		bodyColision.set_deferred("disabled", true)
		bodyHitbox.set_deferred("disabled", true)
		

func move():
	move_and_slide(velocity, Vector2.UP)


#Only colides with "player_weapon" layer
func _on_BodyHitBox_area_entered(_area):
	if(currentState != STATE.DEAD):
		health = health - 50
		if(health <= 0):
			die()
	
