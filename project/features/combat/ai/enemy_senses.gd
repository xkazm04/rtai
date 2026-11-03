class_name EnemySenses
extends RefCounted
## Perception and cover geometry for the pit: line of sight against cover boxes, the sight cone,
## hearing a shot, and the cover spot behind a box away from Rivet. Pure functions on data.

const COVER_GAP_M: float = 0.35


static func blocked(a: Vector2, b: Vector2, cover: Array[Rect2]) -> bool:
	for r: Rect2 in cover:
		if _segment_hits_rect(a, b, r):
			return true
	return false


## Sight: inside the range and the cone (360 degrees once engaged) with a clear line.
static func sees(e: EnemyAgent, target: Vector2, roster: EnemyRoster, cover: Array[Rect2]) -> bool:
	var to: Vector2 = target - e.pos
	var d: float = to.length()
	if d > roster.sight_m:
		return false
	if not e.engaged() and d > 1.5 and e.facing.dot(to / maxf(d, 0.001)) < roster.sight_cos:
		return false
	return not blocked(e.pos, target, cover)


static func hears(e: EnemyAgent, noise: Vector2, roster: EnemyRoster) -> bool:
	return e.pos.distance_to(noise) <= roster.hearing_m


## The spot behind `r` on the far side from `threat`, or Vector2.INF if r is too small.
static func cover_spot(r: Rect2, threat: Vector2, radius: float) -> Vector2:
	var c: Vector2 = r.get_center()
	var away: Vector2 = (c - threat).normalized()
	if away == Vector2.ZERO:
		return Vector2.INF
	var half: Vector2 = r.size * 0.5
	var reach: float = absf(away.x) * half.x + absf(away.y) * half.y
	return c + away * (reach + radius + COVER_GAP_M)


## The nearest free cover spot to `e` that actually hides it from `threat`.
static func best_cover(
	e: EnemyAgent, threat: Vector2, cover: Array[Rect2], taken: Array[Vector2]
) -> Vector2:
	var best: Vector2 = Vector2.INF
	var best_d: float = INF
	for r: Rect2 in cover:
		var spot: Vector2 = cover_spot(r, threat, e.radius())
		if spot == Vector2.INF or not blocked(spot, threat, cover) or _taken(spot, taken):
			continue
		var d: float = e.pos.distance_to(spot)
		if d < best_d:
			best_d = d
			best = spot
	return best


## Where to head for `to` from `from`: `to` itself when the line is clear, else the corner of
## the first box in the way (grown by the body) that is visible and shortest round.
static func detour(from: Vector2, to: Vector2, radius: float, cover: Array[Rect2]) -> Vector2:
	for r: Rect2 in cover:
		if not _segment_hits_rect(from, to, r):
			continue
		var g: Rect2 = r.grow(radius + COVER_GAP_M)
		var best: Vector2 = to
		var best_cost: float = INF
		var corners: Array[Vector2] = [
			g.position, Vector2(g.end.x, g.position.y), g.end, Vector2(g.position.x, g.end.y)
		]
		for c: Vector2 in corners:
			if _segment_hits_rect(from, c, r):
				continue
			var cost: float = from.distance_to(c) + c.distance_to(to)
			if cost < best_cost:
				best_cost = cost
				best = c
		return best
	return to


## Push `p` (a body of `radius`) out of every cover box.
static func push_out(p: Vector2, radius: float, cover: Array[Rect2]) -> Vector2:
	for r: Rect2 in cover:
		var grown: Rect2 = r.grow(radius)
		if not grown.has_point(p):
			continue
		var dl: float = p.x - grown.position.x
		var dr: float = grown.end.x - p.x
		var dt: float = p.y - grown.position.y
		var db: float = grown.end.y - p.y
		var m: float = minf(minf(dl, dr), minf(dt, db))
		if m == dl:
			p.x = grown.position.x
		elif m == dr:
			p.x = grown.end.x
		elif m == dt:
			p.y = grown.position.y
		else:
			p.y = grown.end.y
	return p


static func _taken(spot: Vector2, taken: Array[Vector2]) -> bool:
	for t: Vector2 in taken:
		if t.distance_to(spot) < 1.0:
			return true
	return false


static func _segment_hits_rect(a: Vector2, b: Vector2, r: Rect2) -> bool:
	if r.has_point(a) or r.has_point(b):
		return true
	var p: Vector2 = r.position
	var q: Vector2 = r.end
	var corners: Array[Vector2] = [p, Vector2(q.x, p.y), q, Vector2(p.x, q.y)]
	for i: int in 4:
		if Geometry2D.segment_intersects_segment(a, b, corners[i], corners[(i + 1) % 4]) != null:
			return true
	return false
