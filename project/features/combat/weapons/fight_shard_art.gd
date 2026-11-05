class_name FightShardArt
extends RefCounted
## The homing shard gun's round in the D5 ink (drawn by FightAreasArt for a homing round): a
## cream crystal diamond in a heavy ink rim, pointed along its flight and spinning a little, a
## scratchy ink trail that follows the curve it flew (Shot.trail) and two glints flicking off
## it. View only. Lane gunplay.

const LEN_M: float = 0.62
const WIDE_M: float = 0.2
const TRAIL_PX: float = 7.0
## Stuck shards stay drawn on a corpse. Off: brutality's burst kill pops the body and flies its
## own shards out (KillBurstFx), so ours must not hang in the red mist (REQUEST 30, brutality).
const STUCK_ON_CORPSE: bool = false
## The pop: ticks drawn and cream splinters flung (POP_TICKS 0 draws none).
const POP_TICKS: int = 9
const SPLINTERS: int = 7
## False (`--no-shard-flinch`, the A/B's before): the pop draws as the rocket's burst again.
static var own_pop: bool = true


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
		if not shows_stuck(h):
			continue
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


## Whether the view draws the shards stuck in `h` (GunFx keeps them for brutality either way).
static func shows_stuck(h: Fighter) -> bool:
	return STUCK_ON_CORPSE or h.alive()


## The shard's 1.2 m pop (FightAreasArt for a blast under FightScorch.MIN_BLAST_M): splinters of
## cream crystal flung out of the hit point and a thin ink ring, POP_TICKS long, nothing filled
## over the body. The rocket's burst and smoke used to bury the victim for 0.6 s from the
## landing, so his reaction read late (owner note 2026-11-04, reel chapter 14). View only.
static func pop(ci: CanvasItem, b: Vector3, age: int) -> void:
	if age < 0 or age >= POP_TICKS:
		return
	var c: Vector2 = Vector2(b.x, b.y)
	var k: float = float(age) / float(POP_TICKS)
	ci.draw_arc(
		Ink.px(c),
		b.z * (0.3 + 0.7 * k) * Ink.PX_PER_M,
		0.0,
		TAU,
		32,
		Ink.INK,
		4.0 * (1.0 - k) + 1.0
	)
	for i: int in SPLINTERS:
		var dir: Vector2 = Vector2.from_angle(
			TAU * float(i) / float(SPLINTERS) + float(i % 3) * 0.4
		)
		var near: Vector2 = c + dir * b.z * (0.2 + 0.6 * k)
		var far: Vector2 = near + dir * 0.18 * (1.0 - k * 0.5)
		ci.draw_line(Ink.px(near), Ink.px(far), Ink.INK, 6.0)
		ci.draw_line(Ink.px(near), Ink.px(far), Ink.CREAM, 3.0)
