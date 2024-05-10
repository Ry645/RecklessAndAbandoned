extends Area3D

class_name PickupArea

@onready var collision_shape_3d:CollisionShape3D = %CollisionShape3D

@export var itemNode:ItemMaster
@export var collision:Shape3D

func _ready():
	collision_shape_3d.shape = collision

func getItemHolder() -> ItemHolder:
	return itemNode.getItemHolder()

func killItem():
	itemNode.deleteItem()
