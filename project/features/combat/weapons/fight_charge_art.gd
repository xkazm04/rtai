class_name FightChargeArt
extends RefCounted
## A charge gun in the D5 ink (lane gunplay; the electro gun, brutality REQUEST 12), drawn by
## GunFxArt and FightAreasArt on the print layer: while the held trigger charges, arcs gather
## onto the claw from a closing ring and a cream core swells in ink; the charged round flies as
## a fat double zigzag with a long tail, a big hot head and sparks shed along it. View only.

## The ring the gathering arcs start from, at no charge and at full charge (m from the muzzle).
const GATHER_FAR_M: float = 0.95
const GATHER_NEAR_M: float = 0.4
## The charged bolt's tail (m) and how far its kinks jag off the line (m).
const TAIL_M: float = 3.2
const JAG_M: float = 0.22


## The claw charging: `frac` 0..1 of a full charge at the muzzle `ground` (d8: at the drawn
## muzzle under a tilted view, ShotLift.claw_at; the ground point straight down).
static func crackle(ci: CanvasItem, ground: Vector2, frac: float, tick: int) -> void:
	var at: Vector2 = ShotLift.claw_at(ci, ground)
	var far: float = lerpf(GATHER_FAR_M, GATHER_NEAR_M, frac)
	var arcs: int = 2 + int(frac * 4.0)
	for i: int in arcs:
		var ang: float = TAU * float(i) / float(arcs) + float((tick / 3 + i * 5) % 7) * 0.9
		var from: Vector2 = at + Vector2.from_angle(ang) * far
		zap(ci, from, at, tick + i * 3, 9.0, 0.1, Ink.INK)
		zap(ci, from, at, tick + i * 3, 3.5, 0.1, Ink.CREAM)
	var core: float = (0.06 + 0.16 * frac) * Ink.PX_PER_M
	ci.draw_circle(Ink.px(at), core + 3.5, Ink.INK)
	ci.draw_circle(Ink.px(at), core, Ink.CREAM)
	if frac >= 0.8:  # nearly full: a ring snaps round the core so the release is told
		ci.draw_arc(Ink.px(at), core + 9.0, 0.0, TAU, 20, Ink.INK, 3.0)


## The charged round in flight from its tail to `head`.
static func bolt(ci: CanvasItem, s: Shot, tick: int) -> void:
	var dir: Vector2 = s.vel.normalized()
	var tail: Vector2 = s.pos - dir * minf(s.origin.distance_to(s.pos) + 0.2, TAIL_M)
	zap(ci, tail, s.pos, tick, 18.0, JAG_M, Ink.INK)
	zap(ci, tail, s.pos, tick * 3 + 17, 9.0, JAG_M * 1.6, Ink.INK)
	zap(ci, tail, s.pos, tick, 7.0, JAG_M, Ink.CREAM)
	zap(ci, tail, s.pos, tick * 3 + 17, 3.0, JAG_M * 1.6, Ink.CREAM)
	ci.draw_circle(Ink.px(s.pos), 13.0, Ink.INK)
	ci.draw_circle(Ink.px(s.pos), 8.5, Ink.CREAM)
	for k: int in 3:
		var side: float = sin(float(tick * 3 + k * 11)) * 0.35
		var spark: Vector2 = tail.lerp(s.pos, 0.3 * float(k)) + dir.orthogonal() * side
		ci.draw_circle(Ink.px(spark), 4.5, Ink.INK)
		ci.draw_circle(Ink.px(spark), 2.5, Ink.CREAM)


## An electric zigzag of `width` px jagging `amp` m (kinks every ~0.27 m, re-jagged by `phase`).
static func zap(
	ci: CanvasItem, a: Vector2, b: Vector2, phase: int, width: float, amp: float, c: Color
) -> void:
	var normal: Vector2 = (b - a).orthogonal().normalized()
	var kinks: int = maxi(ceili(a.distance_to(b) / 0.27), 2)
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in kinks + 1:
		var t: float = float(i) / float(kinks)
		var end: bool = i == 0 or i == kinks
		# alternate sides kink to kink (a real zigzag, not a wave), depth varied per kink and tick
		var depth: float = 0.2 + 0.8 * absf(sin(float(phase) * 1.7 + float(i) * 2.3))
		var jag: float = 0.0 if end else (1.0 if i % 2 == 0 else -1.0) * depth * amp
		@warning_ignore("return_value_discarded")
		pts.append(Ink.px(a.lerp(b, t) + normal * jag))
	ci.draw_polyline(pts, c, width, true)
