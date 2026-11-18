class_name ArenaTargets
extends RefCounted
## The range's hit-reporting dummies: each is a Fighter in the CombatArena's hostiles (so Rivet's
## real shots and jabs strike it) with an hp no weapon empties and a trigger that never comes
## off cooldown; its position is the station's motion, re-applied after every arena step. A hit
## is an hp drop: counted, timed and healed. Time to kill runs from the first shot Rivet fires
## at an armed dummy (aimed within ENGAGE_DEG of it) to the hit.

const DUMMY_HP: float = 1000000.0
const NEVER: int = 1 << 30
## A struck dummy stays down this long, then is armed again (the next time-to-kill starts).
const DOWN_TICKS: int = 30
const ENGAGE_DEG: float = 12.0
## An engagement with no hit inside this window lapses (the shots went elsewhere).
const ENGAGE_LAPSE_TICKS: int = 180


class Target:
	extends RefCounted
	var spawn: ArenaStation.Spawn
	var fighter: Fighter
	var home: Vector2 = Vector2.ZERO
	var hits: int = 0
	var engaged_tick: int = -1
	var down_until: int = -1


var targets: Array[Target] = []
## Time-to-kill samples: "<spawn id>" -> Array of seconds.
var ttk_s: Dictionary[String, Array] = {}
var hits_now: int = 0


func add(arena: CombatArena, spawn: ArenaStation.Spawn, base: Vector2, id: int) -> Target:
	var t: Target = Target.new()
	t.spawn = spawn
	t.home = base + spawn.at
	t.fighter = Fighter.make(Fighter.Kind.GUARD, id, t.home, DUMMY_HP)
	t.fighter.radius_m = arena.tuning.human["radius_m"]
	t.fighter.weapon = &"assault-rifle"
	t.fighter.cooldown = NEVER
	arena.hostiles.append(t.fighter)
	targets.append(t)
	return t


## Where the metal dummies (spawn kind "metal") stand now: the CombatArena's metal for the
## electroshock's chain and the arc ball.
func metal_points() -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for t: Target in targets:
		if t.spawn.kind == "metal":
			@warning_ignore("return_value_discarded")
			out.append(t.fighter.pos)
	return out


## After the arena stepped: hits read, dummies placed by their motion, the struck ones re-armed.
func step(tick: int) -> void:
	hits_now = 0
	for t: Target in targets:
		var f: Fighter = t.fighter
		if f.hp < DUMMY_HP:
			if t.down_until < tick:
				t.hits += 1
				hits_now += 1
				_sample(t, tick)
				t.down_until = tick + DOWN_TICKS
			f.hp = DUMMY_HP
		if t.engaged_tick >= 0 and tick - t.engaged_tick > ENGAGE_LAPSE_TICKS:
			t.engaged_tick = -1
		f.cooldown = NEVER
		f.burst_left = 0
		f.exposed = tick >= t.down_until
		f.pos = position(t, tick)


## Where `t` stands at `tick` (pure: static, strafing side to side, approaching then resetting).
static func position(t: Target, tick: int) -> Vector2:
	var s: ArenaStation.Spawn = t.spawn
	var secs: float = float(tick) * SimClock.TICK_DT
	match s.motion:
		"strafe":
			if s.span_m <= 0.0:
				return t.home
			var period: float = 2.0 * s.span_m / maxf(s.speed_mps, 0.01)
			var u: float = fposmod(secs, period) / period
			var tri: float = 1.0 - absf(u * 2.0 - 1.0)
			return t.home + Vector2(0.0, (tri - 0.5) * s.span_m)
		"approach":
			var walked: float = fposmod(secs * s.speed_mps, maxf(s.span_m, 0.01))
			return t.home + Vector2(-walked, 0.0)
	return t.home


## Rivet fired from `from` along `aim`: the armed dummy it points at starts its clock.
## (Only the nearest dummy in the cone: the ones standing behind it in the lane are not engaged.)
func engage(from: Vector2, aim: Vector2, tick: int) -> void:
	var best: Target = null
	for t: Target in targets:
		var to: Vector2 = t.fighter.pos - from
		if tick >= t.down_until and absf(rad_to_deg(aim.angle_to(to))) <= ENGAGE_DEG:
			if best == null or to.length() < best.fighter.pos.distance_to(from):
				best = t
	if best != null and best.engaged_tick < 0:
		best.engaged_tick = tick


func total_hits() -> int:
	var n: int = 0
	for t: Target in targets:
		n += t.hits
	return n


func _sample(t: Target, tick: int) -> void:
	if not ttk_s.has(t.spawn.id) and t.engaged_tick >= 0:
		ttk_s[t.spawn.id] = []
	if t.engaged_tick >= 0:
		ttk_s[t.spawn.id].append(float(tick - t.engaged_tick) * SimClock.TICK_DT)
	t.engaged_tick = -1
