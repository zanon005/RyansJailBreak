extends KinematicBody2D

export var itemName = "PurpleKey"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func pickUpItem():
	AudioPlayer.playSound("res://audios/PickingUpKeys.mp3")
	PlayerInventory.add_item(itemName, 1)
	get_tree().call_group("UI", "addNewItemToUI_Iventory", self, $Sprite.texture.resource_path)
	queue_free()
