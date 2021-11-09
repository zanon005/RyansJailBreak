extends KinematicBody2D

export var run_speed := 350
onready var animation := $PolicialAnimation
#onready var attack_animation := $AttackAnimation    			nao tem....
#onready var attack_hitbox := $AttackHitbox/CollisionShape2D 	nao tem....
var velocity := Vector2()
var isDead := false


func _ready():
	animation.play("walk")
	
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


#Only colides with "player_weapon" layer
func _on_BodyHitBox_area_entered(area):
	#print("hit policial")
	die()
