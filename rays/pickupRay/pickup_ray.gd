extends RayCast3D

class_name PickupRay

func pickup() -> ItemResource:
	if get_collider() != null && get_collider().has_method("killItem"):
		get_collider().killItem()
	else:
		return null
	return get_collider().getItemHolder().itemRes
