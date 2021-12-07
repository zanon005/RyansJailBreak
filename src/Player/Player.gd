extends KinematicBody2D

export var damage := 50
export var run_speed := 350
export var health := 100
onready var playerAnimations := $PlayerAnimations
onready var auxAnimations := $AuxAnimations
signal playerDied()
var isAttacking = false
var velocity := Vector2()
var isInvulnerable = false
enum STATE {ALIVE, DEAD}
var currentState := 0

func _ready():
	currentState = STATE.ALIVE
	pass

func get_input():
	velocity.x = Input.get_action_strength("right")-Input.get_action_strength("left")
	velocity.y = Input.get_action_strength("down")-Input.get_action_strength("up")
	velocity = velocity.normalized() * run_speed
	
	if Input.is_action_just_pressed("attack") and !isAttacking: # only atack if the player isn't attacking
		isAttacking = true # set that the sprite is attacking
	
	if !isAttacking:
		if velocity.x !=0 or velocity.y !=0:
			pass
			playerAnimations.play("walk")
		else:
			pass
			playerAnimations.play("idle")
	else:
		pass
		playerAnimations.play("attack")

func _physics_process(delta):
	if(currentState != STATE.DEAD):
		get_input()
		look_at(get_global_mouse_position())
		velocity = move_and_slide(velocity, Vector2.UP)

func _on_AttackHitbox_body_entered(body):
	#print(body.get_name())
	pass
	
func _on_PickupItemsZone_body_entered(body):
	if(body.is_in_group("Item")):
		print("[PLAYER] Enconstei em: ", body.itemName)
		body.pickUpItem()

func die():
	print("Rip player")
	currentState = STATE.DEAD
	emit_signal("playerDied")

# Only colides with 'enemies'
func _on_BodyHitbox_body_entered(body):
	if(currentState != STATE.DEAD && body.is_in_group("Enemy") && !isInvulnerable):
		isInvulnerable = true
		auxAnimations.play("hit")
		health = health - body.getEnemyDamage()
		if(health <= 0): die()
		
func _on_PlayerAnimations_animation_finished(anim_name):
	if(anim_name == "attack"):
		isAttacking = false

func _on_AuxAnimations_animation_finished(anim_name):
	if(anim_name == "hit"):
		isInvulnerable = false
