extends KinematicBody2D

export var run_speed := 350
onready var feet_animation := $FeetAnimation
onready var body_animation := $BodyAnimation
onready var attack_animation := $AttackAnimation
onready var attack_hitbox := $AttackHitbox/CollisionShape2D
var isAttacking = false
var velocity := Vector2()

func _ready():
	feet_animation.play("idle")
	body_animation.play("idle")

func get_input():
	velocity.x = Input.get_action_strength("right")-Input.get_action_strength("left")
	velocity.y = Input.get_action_strength("down")-Input.get_action_strength("up")
	velocity = velocity.normalized() * run_speed
	
	if Input.is_action_just_pressed("attack") and !isAttacking: # only atack if the sprite isn't attacking
		isAttacking = true # set that the sprite is attacking
	
	if !isAttacking:
		attack_animation.stop()
		attack_animation.hide()
		body_animation.show()
		attack_hitbox.disabled = true
		if velocity.x !=0 or velocity.y !=0:
			feet_animation.play("walk")
			body_animation.play("walk")
		else:
			feet_animation.play("idle")
			body_animation.play("idle")
	else:
		attack_hitbox.disabled = false
		attack_animation.show()
		body_animation.hide()
		attack_animation.play("attack")

func _physics_process(delta):
	get_input()
	look_at(get_global_mouse_position())
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_AtackAnimation_animation_finished():
	isAttacking = false


func _on_AttackHitbox_body_entered(body):
	print(body.get_name())
