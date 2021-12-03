extends KinematicBody2D

export var run_speed := 300
export var health := 100
onready var animation := $PolicialAnimation
var velocity := Vector2()
var isDead := false

var path : Array = [] # Array com a lista de pontos para se mover
onready var levelNavigation := get_node("LevelNavigation")
onready var player := get_node("Player")
onready var lineToPathTarget := $LineToPathTarget

func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if(tree.has_group('LevelNavigation')):
		# 	Se tem 'LevelNavigation' entao busca o primeiro nodo filho dele
		# no caso o tilemap 'ContornoEChao'
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if(tree.has_group('Player')):
		player = tree.get_nodes_in_group("Player")[0]
	animation.play("walk")
	
func _physics_process(delta):
	lineToPathTarget.global_position = Vector2.ZERO
	if(player && levelNavigation):
		generate_path()
		navigate()
	move()

func navigate(): #Defines the next position the enemy must moove
	if(path.size() > 1):
		velocity = global_position.direction_to(path[1]) * run_speed
		
		#	If the current global position is equal to current path point
		# then pop this point that is already visited
		if(global_position == path[0]):
			path.pop_front()
	
func generate_path():
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position, false)
		lineToPathTarget.points = path

func die():
	if(!isDead):
		var rand = randi() % 2
		match rand:
			0:
				animation.play("die1")
			1:
				animation.play("die2")
		isDead = true
	#queue_free()

func move():
	move_and_slide(velocity, Vector2.UP)


#Only colides with "player_weapon" layer
func _on_BodyHitBox_area_entered(area):
	health = health - 50
	if(health <= 0):
		die()
	
