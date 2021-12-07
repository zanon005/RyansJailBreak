extends Node2D


onready var player := $Player

func _ready() -> void:
	#print("Total children: "+str(get_child_count()))
	#$Music.play()
	#print("Audio bus count:"+str(AudioServer.bus_count))
	pass
			
func _physics_process(delta: float) -> void:
	
	# Se o jogador passar do limite vertical da cena, game over!
	#if player.position.y > sceneLimit.position.y:
	#	get_tree().change_scene("res://Levels/GameOver.tscn")
	pass

func _process(delta):
	
	if $AudioStreamPlayer.playing == false:
		$AudioStreamPlayer.play()
	pass
