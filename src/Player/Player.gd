extends KinematicBody2D

export var run_speed := 350
onready var player_animation := $AnimationPlayer
var isAttacking = false
var velocity := Vector2()

func _ready():
	pass

func get_input():
	velocity.x = Input.get_action_strength("right")-Input.get_action_strength("left")
	velocity.y = Input.get_action_strength("down")-Input.get_action_strength("up")
	velocity = velocity.normalized() * run_speed
	
	if Input.is_action_just_pressed("attack") and !isAttacking: # only atack if the player isn't attacking
		isAttacking = true # set that the sprite is attacking
	
	if !isAttacking:
		if velocity.x !=0 or velocity.y !=0:
			player_animation.play("walk")
		else:
			player_animation.play("idle")
	else:
		player_animation.play("attack")

func _physics_process(delta):
	get_input()
	look_at(get_global_mouse_position())
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_AttackHitbox_body_entered(body):
	print(body.get_name())


func _on_AnimationPlayer_animation_finished(anim_name):
	print("fim animacao ", anim_name) #Nao esta sendo executada nunca
	if(anim_name == "attack"):
		isAttacking = false
