extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var doorClosingTime = 3
enum STATE {CLOSED, OPEN}
var currentState := 0
onready var sprite = $Sprite
var timer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	currentState = STATE.CLOSED

func openDoor():
	if(currentState != STATE.OPEN):	
		currentState = STATE.OPEN
		sprite.texture = load("res://Sprites/Misc/porta-vermelha-aberta.png")
		$DoorColisionArea/CollisionShape2D.set_deferred("disabled", true)
		$CollisionShape2D.set_deferred("disabled", true)
		createTimerToAutoCloseDoor()

func closeDoor():
	if(currentState != STATE.CLOSED):
		currentState = STATE.CLOSED
		sprite.texture = load("res://Sprites/Misc/porta-vermelha.png")
		$DoorColisionArea/CollisionShape2D.set_deferred("disabled", false)
		$CollisionShape2D.set_deferred("disabled", false)

func createTimerToAutoCloseDoor():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(doorClosingTime)
	timer.connect("timeout",self,"_on_timer_timeout") 
	#timeout is what says in docs, in signals
	#self is who respond to the callback
	#_on_timer_timeout is the callback, can have any name
	add_child(timer) #to process
	timer.start() #to start

func _on_DoorColisionArea_body_entered(body):
	if(body.is_in_group("Player")):
		print("Colidi com player: ", body.get_name())
		if(PlayerInventory.checkIfHasDoorKey("RedKey")):
			openDoor()
	elif(body.is_in_group("Enemy")):
		print("Colidi com Inimigo: ", body.get_name())
		openDoor()
		
func _on_timer_timeout():
	print("Acabou o tempo...")
	closeDoor()
