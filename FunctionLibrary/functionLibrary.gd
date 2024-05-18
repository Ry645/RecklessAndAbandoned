class_name FunctionLibrary

static func vec2ToVec3(vector:Vector2, yValue = 0) -> Vector3:
	return Vector3(vector.x, yValue, vector.y)

static func vec3ToVec2(vector:Vector3) -> Vector2:
	return Vector2(vector.x, vector.z)
