class_name Sweep
extends RefCounted
## Swept tests for a round moving from `a` to `b` in one tick: where along the segment (t in
## 0..1) it first touches a circle or a cover rectangle, or -1.0 for a miss. Exact, no tunnelling.


static func circle(a: Vector2, b: Vector2, centre: Vector2, r: float) -> float:
	var d: Vector2 = b - a
	var f: Vector2 = a - centre
	var c: float = f.dot(f) - r * r
	if c <= 0.0:
		return 0.0
	var qa: float = d.dot(d)
	if qa <= 1e-12:
		return -1.0
	var qb: float = 2.0 * f.dot(d)
	var disc: float = qb * qb - 4.0 * qa * c
	if disc < 0.0:
		return -1.0
	var t: float = (-qb - sqrt(disc)) / (2.0 * qa)
	return t if t >= 0.0 and t <= 1.0 else -1.0


## Slab test against an axis-aligned rectangle (cover, a wall, a building footprint).
static func rect(a: Vector2, b: Vector2, box: Rect2) -> float:
	if box.has_point(a):
		return 0.0
	var d: Vector2 = b - a
	var t_in: float = 0.0
	var t_out: float = 1.0
	for axis: int in 2:
		var lo: float = box.position[axis]
		var hi: float = box.end[axis]
		if absf(d[axis]) < 1e-12:
			if a[axis] < lo or a[axis] > hi:
				return -1.0
			continue
		var t1: float = (lo - a[axis]) / d[axis]
		var t2: float = (hi - a[axis]) / d[axis]
		t_in = maxf(t_in, minf(t1, t2))
		t_out = minf(t_out, maxf(t1, t2))
		if t_in > t_out:
			return -1.0
	return t_in
