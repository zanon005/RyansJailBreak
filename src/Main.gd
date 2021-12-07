extends Node2D

onready var player := $Player

func _ready() -> void:
	connect("replayLastScene", self, "_on_ReplayLastScene")
	#print("Total children: "+str(get_child_count()))
	#$Music.play()
	#print("Audio bus count:"+str(AudioServer.bus_count))
	pass

#func _physics_process(delta: float) -> void:
	# Se o jogador passar do limite vertical da cena, game over!
	#if player.position.y > sceneLimit.position.y:
	#	get_tree().change_scene("res://Levels/GameOver.tscn")
	#pass

func _process(delta):
	pass

func _on_CurrentLevel_scenePlayerDied():
	print("Main, player died")
	get_tree().change_scene("res://src/Levels/GameOver/GameOver.tscn")
	
func _on_ReplayLastScene():
	print("Replay!")


func _on_Fase2_scenePlayerDied():
	get_tree().change_scene("res://src/Levels/GameOver/GameOver.tscn")
