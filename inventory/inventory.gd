extends Node2D

class_name Inventory

var itemList:Array[ItemResource]

func addToInventory(itemRes:ItemResource):
	if itemRes == null:
		return
	itemList.append(itemRes)
	printItemList()

func printItemList():
	var toPrint:String = "["
	for i in range(itemList.size() - 1):
		toPrint += itemList[i].name + ", "
	toPrint += itemList[itemList.size() - 1].name + "]"
	print(toPrint)
