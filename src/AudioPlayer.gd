extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if self.playing == false:
		self.play()

func playSound(soundFilePath: String):
	var soundPlayer = AudioStreamPlayer.new()
	add_child(soundPlayer)
	soundPlayer.stream = load(soundFilePath)
	soundPlayer.play()
	
	yield(soundPlayer, "finished")
	soundPlayer.queue_free()

func playTheme():
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_playing():
		play()
