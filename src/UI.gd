extends CanvasLayer


onready var ui_Inventory = $Inventory

var itensOnUI = {} #itemName, [item, hBox]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func addNewItemToUI_Iventory(item, itemTexture):
	print("Chamei a UI!: ", item, itemTexture)
	var newHbox = HBoxContainer.new()
	newHbox.alignment = HBoxContainer.ALIGN_CENTER
	
	var newTextureRect = TextureRect.new()
	newTextureRect.stretch_mode = TextureRect.STRETCH_SCALE
	newTextureRect.texture = load(itemTexture)
	newTextureRect.rect_min_size = Vector2(30,30)
	
	newHbox.add_child(newTextureRect)
	ui_Inventory.add_child(newHbox)
	
	itensOnUI[item.itemName] = [item, newHbox]
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
