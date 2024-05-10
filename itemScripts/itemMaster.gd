extends Node3D

class_name ItemMaster

var itemHolder:ItemHolder

func getItemHolder():
	return itemHolder

func deleteItem():
	itemHolder.deleteItem()
