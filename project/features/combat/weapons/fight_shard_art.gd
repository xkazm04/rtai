class_name FightShardArt
extends RefCounted
## The homing shard gun's round in the D5 ink (drawn by FightAreasArt for a homing round): a
## cream crystal diamond in a heavy ink rim, pointed along its flight and spinning a little, a
## scratchy ink trail that follows the curve it flew (Shot.trail) and two glints flicking off
## it. View only. Lane gunplay.

const LEN_M: float = 0.62
const WIDE_M: float = 0.2
const TRAIL_PX: float = 7.0


static func shard(ci: CanvasItem, s: Shot, tick: int) -> void:
	var dir: Vector2 = s.vel.normalized()
	_trail(ci, s)
	var side: Vector2 = dir.orthogonal() * WIDE_M * (0.75 + 0.25 * sin(float(tick) * 0.8))
	var tip: Vector2 = s.pos + dir * LEN_M * 0.6
	var back: Vector2 = s.pos - dir * LEN_M * 0.4
	var gem: PackedVector2Array = PackedVector2Array(
		[Ink.px(tip), Ink.px(s.pos + side), Ink.px(back), Ink.px(s.pos - side), Ink.px(tip)]
	)
	ci.draw_polyline(gem, Ink.INK, 6.0, true)
	ci.draw_colored_polygon(gem.slice(0, 4), Ink.CREAM)
	ci.draw_line(Ink.px(back), Ink.px(tip), Ink.INK, 2.0)
	if tick % 6 < 3:
		var g: Vector2 = s.pos + dir.orthogonal() * 0.22 * (1.0 if tick % 12 < 6 else -1.0)
		ci.draw_line(Ink.px(g - dir * 0.08), Ink.px(g + dir * 0.08), Ink.CREAM, 3.0)


## Ink scratches along the flown curve, thinning toward the tail, broken every other step.
static func _trail(ci: CanvasItem, s: Shot) -> void:
	var n: int = s.trail.size()
	for i: int in range(1, n):
		if i % 2 == 1 and i < n - 2:
			continue
		var k: float = float(i) / float(n)
		ci.draw_line(Ink.px(s.trail[i - 1]), Ink.px(s.trail[i]), Ink.INK, TRAIL_PX * k + 1.0)
	if n > 0:
		ci.draw_line(Ink.px(s.trail[n - 1]), Ink.px(s.pos), Ink.INK, TRAIL_PX)


## Every shard stuck in a hostile (GunFx.stuck): the back half of the crystal standing out of
## the body against its flight, so the corpse reads as hit by the swarm. View only.
static func stuck(ci: CanvasItem, fx: GunFx, arena: CombatArena) -> void:
	for h: Fighter in arena.hostiles:
		for v: Vector3 in fx.stuck_shards(h.id):
			var dir: Vector2 = Vector2.from_angle(v.z)
			var root: Vector2 = h.pos + Vector2(v.x, v.y)
			var back: Vector2 = root - dir * LEN_M * 0.55
			var side: Vector2 = dir.orthogonal() * WIDE_M * 0.6
			var mid: Vector2 = root - dir * LEN_M * 0.22
			var gem: PackedVector2Array = PackedVector2Array(
				[Ink.px(root), Ink.px(mid + side), Ink.px(back), Ink.px(mid - side), Ink.px(root)]
			)
			ci.draw_polyline(gem, Ink.INK, 5.0, true)
			ci.draw_colored_polygon(gem.slice(0, 4), Ink.CREAM)
