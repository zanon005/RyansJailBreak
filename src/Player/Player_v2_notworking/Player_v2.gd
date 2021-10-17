extends KinematicBody2D

export var run_speed := 350
onready var feet_animation := $FeetAnimation
onready var body_animation := $BodyAnimation
onready var attack_animation := $AttackAnimation
onready var attack_hitbox := $AttackHitbox/CollisionShape2D
var isAttacking = false
var velocity := Vector2.ZERO

enum { WALK, ATTACK, IDLE}
var current_state := IDLE
var enter_state = true

# BASED ON https://www.youtube.com/watch?v=PEsxqii5r_I

# STATE FUNCTIONS
func _attack_state():
	if enter_state:
		attack_animation.show()
		attack_animation.play("attack")
		enter_state = false
	#_set_state(_check_attack_state())

func _walk_state():
	if enter_state:
		body_animation.play("walk")
		feet_animation.play("walk")
		enter_state = false
	_set_state(_check_walk_state())

func _idle_state():
	if enter_state:
		body_animation.play("idle")
		feet_animation.play("idle")
		enter_state = false
	_set_state(_check_idle_state())
	
# CHECK FUNCTIONS
#func _check_attack_state():
	#var new_state = current_state
	#return new_state

func _check_walk_state():
	var new_state = current_state
	if(velocity.x == 0 and velocity.y == 0):
		new_state = IDLE
	elif Input.is_action_just_pressed("attack") and !isAttacking:
		body_animation.hide()
		body_animation.stop()
		new_state = ATTACK
	return new_state
	
func _check_idle_state():
	var new_state = current_state
	if( velocity.x != 0 or velocity.y != 0 ):
		new_state = WALK
	elif Input.is_action_just_pressed("attack") and !isAttacking:
		body_animation.hide()
		body_animation.stop()
		new_state = ATTACK
	return new_state


# HELPER FUNCTIONS 
func _on_AttackAnimation_animation_finished():
	isAttacking = false
	attack_animation.hide()
	body_animation.show()
	_set_state(IDLE)
	
func _move_control():
	velocity.x = Input.get_action_strength("right")-Input.get_action_strength("left")
	velocity.y = Input.get_action_strength("down")-Input.get_action_strength("up")

func _move_and_slide():
	velocity = velocity.normalized() * run_speed
	velocity = move_and_slide(velocity, Vector2.UP)

func _set_state(new_state):
	if new_state != current_state:
		enter_state = true
	current_state = new_state

# PROCESS FUNCTION
func _physics_process(delta):
	match current_state:
		WALK:
			_walk_state()
		ATTACK:
			_attack_state()
		IDLE:
			_idle_state()
	print(current_state)

	_move_control()
	_move_and_slide()
	look_at(get_global_mouse_position())
