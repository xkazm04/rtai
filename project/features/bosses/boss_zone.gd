class_name BossZone
extends RefCounted
## Where a boss attack lands, from the aim locked at the end of its tell: a line or charge lane
## (range_m long, width_m wide), a cone (range_m, arc_deg), a circle (radius_m round the origin).
## The telegraph draws exactly this zone, so what the player reads is what hits (no hidden reach).


## True when a body of radius `r` at `p` is inside attack `a` fired from `origin` along `dir`.
static func hits(a: BossAttack, origin: Vector2, dir: Vector2, p: Vector2, r: float) -> bool:
	match a.shape:
		BossAttack.Shape.LINE, BossAttack.Shape.CHARGE:
			return _in_lane(origin, dir, a.range_m, a.width_m * 0.5 + r, p)
		BossAttack.Shape.CONE:
			return _in_cone(a, origin, dir, p, r)
		BossAttack.Shape.CIRCLE:
			return origin.distance_to(p) <= a.radius_m + r
	return false


## A charge's hit lane this tick: the body's own front (radius + width), not the whole lane, so
## a target behind the charging boss or beside its stopped path is never struck.
static func body_hits(body_at: Vector2, body_r: float, a: BossAttack, p: Vector2, r: float) -> bool:
	return body_at.distance_to(p) <= body_r + a.width_m * 0.5 + r


static func _in_lane(o: Vector2, dir: Vector2, length: float, half_w: float, p: Vector2) -> bool:
	var d: Vector2 = p - o
	var along: float = d.dot(dir)
	if along < 0.0 or along > length:
		return false
	return absf(d.dot(dir.orthogonal())) <= half_w


static func _in_cone(a: BossAttack, o: Vector2, dir: Vector2, p: Vector2, r: float) -> bool:
	var d: Vector2 = p - o
	var dist: float = d.length()
	var half: float = deg_to_rad(a.arc_deg) * 0.5
	if dist > a.range_m + r:
		return false
	if dist <= r:
		return true
	var slack: float = asin(clampf(r / dist, 0.0, 1.0))  # a body grazing the edge is in
	return absf(dir.angle_to(d)) <= half + slack
