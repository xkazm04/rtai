class_name RigStress
extends RefCounted
## The F-09b rig stress: N people around a walking Rivet (cops aiming and shooting at him, peds
## walking, fleeing, getting hit and dying; Rivet punching and rolling), fed to CharacterRigs on
## the fixed tick. Deterministic, no RNG: every pattern is a function of the row and the tick.
## Measures the rig work per tick (selection + full-rig poses) and the baked-cell lookups for
## everyone else, against STANDARDS section 20 (rig cost 0.3 ms target, 1 ms hard limit).

const PX: float = 32.0
const TARGET_MS: float = 0.3
const HARD_MS: float = 1.0
## Ticks left out of the metrics (BenchStats skips its first 120 frames the same way).
const WARMUP_TICKS: int = 60

var rigs: CharacterRigs = null
var n: int = 0
var rig_us: PackedInt64Array = PackedInt64Array()
var baked_us: PackedInt64Array = PackedInt64Array()
var full_counts: PackedInt32Array = PackedInt32Array()
## Sum of the looked-up cells, so the lookups cannot be optimised into nothing.
var cell_sum: int = 0


func _init(p_rigs: CharacterRigs, people: int) -> void:
	rigs = p_rigs
	n = people


func run(ticks: int) -> void:
	for t: int in ticks:
		_feed(t)
		rigs.step_ticks(1)
		var t0: int = Time.get_ticks_usec()
		for i: int in rigs.feed.count:
			if not rigs.full_row(i):
				cell_sum += rigs.baked_cell(i, t * SimClock.TICK_DT)
		if t < WARMUP_TICKS:
			continue
		@warning_ignore_start("return_value_discarded")
		baked_us.append(Time.get_ticks_usec() - t0)
		rig_us.append(rigs.last_us)
		full_counts.append(rigs.full_count())
		@warning_ignore_restore("return_value_discarded")


func metrics() -> Dictionary[String, float]:
	var sorted: PackedInt64Array = rig_us.duplicate()
	sorted.sort()
	var m: int = sorted.size()
	var sum: int = 0
	for v: int in sorted:
		sum += v
	return {
		"people": float(n),
		"ticks": float(m),
		"rigMsP50": sorted[m / 2] / 1000.0 if m > 0 else 0.0,
		"rigMsP99": sorted[mini(m - 1, floori(m * 0.99))] / 1000.0 if m > 0 else 0.0,
		"rigMsMax": sorted[m - 1] / 1000.0 if m > 0 else 0.0,
		"rigMsAvg": sum / 1000.0 / maxi(1, m),
		"bakedLookupMsAvg": _avg(baked_us) / 1000.0,
		"fullRigsMax": float(_max(full_counts)),
		"prewarmMs": rigs.prewarm_ms,
		"rigsBuilt": float(rigs.rig_count()),
		"poolGrown": float(rigs.pool().grown),
	}


func _feed(t: int) -> void:
	var f: RigFeed = rigs.feed
	var time: float = t * SimClock.TICK_DT
	var me: Vector2 = Vector2(cos(time * 0.4), sin(time * 0.4)) * 6.0 * PX
	rigs.focus = me
	@warning_ignore("return_value_discarded")
	f.put(0, 1, BodyPlan.Kind.RIVET, me, Vector2(-sin(time * 0.4), cos(time * 0.4)) * 77.0)
	if t % 60 == 0:
		f.clip[0] = RigClips.Clip.PUNCH
		f.clip_arg[0] = float(1 + (t / 60) % 3)
	elif t % 137 == 0:
		f.clip[0] = RigClips.Clip.ROLL
	for i: int in range(1, n):
		_person(f, i, t, me)


func _person(f: RigFeed, i: int, t: int, me: Vector2) -> void:
	var time: float = t * SimClock.TICK_DT
	var cop: bool = i % 4 == 0
	var ring: float = (2.0 + (i % 23) * 1.2) * PX
	var ang: float = i * 2.399 + time * (0.15 + (i % 5) * 0.04) * (1.0 if i % 2 == 0 else -1.0)
	var at: Vector2 = me + Vector2.from_angle(ang) * ring
	var vel: Vector2 = Vector2.from_angle(ang + PI * 0.5) * ring * 0.2
	var kind: BodyPlan.Kind = BodyPlan.Kind.COP if cop else BodyPlan.Kind.PED
	@warning_ignore("return_value_discarded")
	f.put(i, 100 + i, kind, at, vel)
	if cop:
		f.aim[i] = me
		f.face[i] = (me - at).angle()
		f.flags[i] = RigFeed.Flag.GUN_OUT | RigFeed.Flag.AIMING
		if (t + i * 7) % 30 == 0:
			f.clip[i] = RigClips.Clip.SHOOT
	elif (t + i * 11) % 240 < 90:
		f.flags[i] = RigFeed.Flag.FLEE
	if (t + i * 13) % 42 == 0:
		f.clip[i] = RigClips.Clip.HIT
		f.clip_arg[i] = (at - me).angle()
	if i % 9 == 0 and t > 180 + i * 3:
		f.flags[i] |= RigFeed.Flag.DEAD
		f.vel[i] = Vector2.ZERO


static func _avg(a: PackedInt64Array) -> float:
	var s: int = 0
	for v: int in a:
		s += v
	return float(s) / maxi(1, a.size())


static func _max(a: PackedInt32Array) -> int:
	var m: int = 0
	for v: int in a:
		m = maxi(m, v)
	return m
