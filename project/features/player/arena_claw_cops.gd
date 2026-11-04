class_name ArenaClawCops
extends ArenaHook
## rivet-arsenal's arena station (arena_stations/rivet-arsenal.json): real CombatArena guards on
## the hub for Rivet's claw. They walk at him (GuardBrain) but never fire (the trigger is held on
## cooldown each tick); a `spar_` spawn has SPAR_HP so the whole combo plays on it, the others the
## human hp (one hit). A dead cop stands again at its spawn RESPAWN_TICKS later.

const SPAR_HP: float = 4.0
const RESPAWN_TICKS: int = 150
const NEVER: int = 1 << 30
const FIRST_ID: int = 3000
## A standing claw cop keeps this far from Rivet's centre (m), inside every melee reach (a hit
## lands to reach + the body's radius: the claw's 1.4 + 0.45), and the cops keep SPACING_M apart:
## GuardBrain walks them straight in (REQUEST 26 -> enemy-ai had no taker tonight). PASSES lets the
## ring and the spacing settle together. STANDOFF_M 0 = the old pile-up. NOT ENOUGH for the look:
## a drawn cop is about 1.27 m across, so 1.0 m still overlaps their rigs at 64 px/m; 1.3 m costs
## scenario_rivet_chainsaw a kill (2 < 3 in its window), so 1.0 stays until that is understood.
const STANDOFF_M: float = 1.25
const SPACING_M: float = 1.0
const PASSES: int = 3
const PIN_TICKS: int = 30

var cops: Array[Fighter] = []
var homes: PackedVector2Array = PackedVector2Array()
var hp_of: PackedFloat32Array = PackedFloat32Array()
var dead_since: PackedInt32Array = PackedInt32Array()
var kills: int = 0
var _host: ArenaStage = null


func setup(stage: ArenaStage, _ctx: WorldContext) -> void:
	_host = stage
	var human: float = stage.arena.tuning.human["hp"]
	for i: int in station.spawns.size():
		var sp: ArenaStation.Spawn = station.spawns[i]
		var hp: float = SPAR_HP if sp.id.begins_with("spar_") else human
		var at: Vector2 = stage.plan.base + sp.at
		var f: Fighter = Fighter.make(Fighter.Kind.GUARD, FIRST_ID + i, at, hp)
		f.radius_m = stage.arena.tuning.human["radius_m"]
		f.weapon = &"assault-rifle"
		f.cooldown = NEVER
		f.facing = Vector2.UP
		stage.arena.hostiles.append(f)
		cops.append(f)
		@warning_ignore_start("return_value_discarded")
		homes.append(at)
		hp_of.append(hp)
		dead_since.append(-1)
		@warning_ignore_restore("return_value_discarded")


func step(stage: ArenaStage, tick: int) -> void:
	for i: int in cops.size():
		var f: Fighter = cops[i]
		f.cooldown = NEVER
		f.burst_left = 0
		if f.alive():
			continue
		if dead_since[i] < 0:
			dead_since[i] = tick
			kills += 1
		elif tick - dead_since[i] >= RESPAWN_TICKS:
			f.hp = hp_of[i]
			f.pos = homes[i]
			dead_since[i] = -1
	stand_off(cops, stage.arena.rivet.pos, STANDOFF_M, SPACING_M, tick)


## Push standing cops apart to `spacing`, then out to `ring` round `me` (the ring wins, last).
## A cop hit in the last PIN_TICKS is left where the hit put him (the knockback, the grind's
## teeth); the other cop of a pair takes the whole push.
static func stand_off(
	fs: Array[Fighter], me: Vector2, ring: float, spacing: float, tick: int
) -> void:
	var free: Array[bool] = []
	for f: Fighter in fs:
		free.append(f.alive() and tick - f.hurt_tick > PIN_TICKS)
	for n: int in PASSES:
		_spread(fs, free, spacing)
		_ring(fs, free, me, ring)


static func _spread(fs: Array[Fighter], free: Array[bool], spacing: float) -> void:
	for i: int in fs.size():
		for j: int in range(i + 1, fs.size()):
			var gap: Vector2 = fs[j].pos - fs[i].pos
			var d: float = gap.length()
			var movers: int = int(free[i]) + int(free[j])
			if movers == 0 or not fs[i].alive() or not fs[j].alive() or d >= spacing or d < 0.001:
				continue
			var push: Vector2 = gap / d * (spacing - d) / movers
			if free[i]:
				fs[i].pos -= push
			if free[j]:
				fs[j].pos += push


static func _ring(fs: Array[Fighter], free: Array[bool], me: Vector2, ring: float) -> void:
	for i: int in fs.size():
		var to: Vector2 = fs[i].pos - me
		if free[i] and to.length() < ring:
			var dir: Vector2 = to.normalized() if to.length() > 0.001 else Vector2.from_angle(i)
			fs[i].pos = me + dir * ring


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(kills)
	for f: Fighter in cops:
		out.put_float(f.hp)


func telemetry() -> Dictionary:
	var out: Dictionary = {"claw_kills": kills}
	if _host != null and _host.pilot != null:
		out["claw_hits"] = _host.pilot.melee.landed
		out["claw_whiffs"] = _host.pilot.melee.whiffs
		out["claw_swings"] = _host.pilot.melee_swings
		out["shock_discharges"] = _host.pilot.shock.discharges
		out["shock_landed"] = _host.pilot.shock.landed
	return out
