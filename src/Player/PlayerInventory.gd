extends Node


var inventory = {} # index: ['name', quantity]
var itemCount = 0

func add_item(itemName, itemQuantity):
	for index_item in inventory:
		if (inventory[index_item][0] == itemName):
			inventory[index_item][1] += itemQuantity
			return
			
	inventory[itemCount] = [itemName, itemQuantity]
	itemCount += 1
	
func checkIfHasDoorKey(keyName):
	for index_item in inventory:
		if (inventory[index_item][0] == keyName):
			return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
