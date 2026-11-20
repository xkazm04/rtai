class_name OhmArm
extends RefCounted
## The joint between two fixed-length pieces, bent toward the chosen side of the reach vector.


static func joint(a: Vector2, b: Vector2, upper: float, fore: float, side: float) -> Vector2:
	var d: float = clampf(a.distance_to(b), 0.02, upper + fore - 0.001)
	var along: float = (upper * upper - fore * fore + d * d) / (2.0 * d)
	var out: float = sqrt(maxf(0.0, upper * upper - along * along))
	var dir: Vector2 = (b - a).normalized() if a.distance_to(b) > 0.001 else Vector2.RIGHT
	return a + dir * along + dir.orthogonal() * out * -side
