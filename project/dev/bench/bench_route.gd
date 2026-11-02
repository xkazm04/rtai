class_name BenchRoute
extends RefCounted
## The crowded-drive lap on the road grid (road centres at 64k + 12 m), in the right-hand lane,
## slowing to 9 m/s into each corner and up to 25 m/s on the straights.

const A: float = 64.0 * 4 + 12.0
const B: float = 64.0 * 26 + 12.0
const C: float = 64.0 * 17 + 12.0
const V_CORNER: float = 9.0
const V_STRAIGHT: float = 25.0

var points: PackedVector2Array = PackedVector2Array(
	[
		Vector2(A, A + 2),
		Vector2(B - 2, A + 2),
		Vector2(B - 2, C - 2),
		Vector2(A + 2, C - 2),
		Vector2(A + 2, A + 2)
	]
)
var length: float = 0.0


func _init() -> void:
	for i: int in points.size() - 1:
		length += points[i].distance_to(points[i + 1])


## [position, distance to the nearest corner] at arc length s (wrapping).
func at(s: float) -> Array:
	var rest: float = fmod(s, length)
	for i: int in points.size() - 1:
		var seg: float = points[i].distance_to(points[i + 1])
		if rest <= seg:
			var dir: Vector2 = (points[i + 1] - points[i]) / seg
			return [points[i] + dir * rest, minf(rest, seg - rest)]
		rest -= seg
	return [points[0], 0.0]


func speed_at(s: float) -> float:
	var corner: float = at(s)[1]
	return lerpf(V_CORNER, V_STRAIGHT, clampf((corner - 6.0) / 60.0, 0.0, 1.0))
