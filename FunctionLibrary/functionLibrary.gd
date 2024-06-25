class_name FunctionLibrary

static func vec2ToVec3(vector:Vector2, yValue = 0) -> Vector3:
	return Vector3(vector.x, yValue, vector.y)

static func vec3ToVec2(vector:Vector3) -> Vector2:
	return Vector2(vector.x, vector.z)

static func keySearch(array, toFind, keyIndex = 0) -> int:
	if array.size() == 0:
		return -1
	
	var level = findArrayLevel(array, keyIndex)
	for i in range(array.size()):
		var temp = array[i]
		for j in range(level):
			temp = temp[keyIndex]
		if temp == toFind:
			return i
	
	return -1

#0 is regular, 1 is nested, 2 is nested nested, etc
static func findArrayLevel(array, keyIndex, counter = 0):
	if array[keyIndex] is Array:
		counter += 1
		return findArrayLevel(array[keyIndex], keyIndex, counter)
	else:
		return counter
