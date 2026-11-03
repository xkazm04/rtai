class_name PitLayout
extends RefCounted
## The standard pit (40 x 28 m): Rivet starts on the west side, enemies pour in from the east,
## five cover boxes between (crates and a low wall). The dev scene and the scenarios share it so
## a number measured in one holds in the other.

const RIVET_START: Vector2 = Vector2(-12.0, 0.0)
const SPAWN_X: float = 14.0
const BOXES: Array[Rect2] = [
	Rect2(-3.0, -7.0, 2.0, 2.0),
	Rect2(-3.0, 5.0, 2.0, 2.0),
	Rect2(3.0, -1.5, 1.2, 3.0),
	Rect2(7.0, -9.0, 2.5, 1.2),
	Rect2(7.0, 7.8, 2.5, 1.2),
]


static func build(seed_value: int, with_cover: bool = true, events: EventBus = null) -> EnemyPit:
	var rngs: RngRegistry = RngRegistry.new(seed_value)
	var pit: EnemyPit = EnemyPit.new(EnemyRoster.shipped(), rngs.stream(&"enemy_ai"), events)
	if with_cover:
		pit.cover.assign(BOXES)
	pit.rivet_pos = RIVET_START
	return pit


## `ids` spawned in a column down the east edge, already alert (the pit fight starts hot).
static func squad(pit: EnemyPit, ids: Array[StringName], hot: bool = true) -> void:
	var n: int = ids.size()
	for i: int in n:
		var y: float = (float(i) - float(n - 1) * 0.5) * 3.0
		var e: EnemyAgent = pit.spawn(ids[i], Vector2(SPAWN_X, y))
		if hot:
			e.last_seen = pit.rivet_pos
			e.enter(EnemyAgent.State.ENGAGE)


## `ids` spawned at `spots` (metres), already alert: a staged fight (the rig clips).
static func place(pit: EnemyPit, ids: Array[StringName], spots: PackedVector2Array) -> void:
	for i: int in ids.size():
		var e: EnemyAgent = pit.spawn(ids[i], spots[i])
		e.last_seen = pit.rivet_pos
		e.enter(EnemyAgent.State.ENGAGE)


static func many(id: StringName, n: int) -> Array[StringName]:
	var out: Array[StringName] = []
	for i: int in n:
		out.append(id)
	return out


## A stable hash of the whole fight state (the determinism check).
static func digest(pit: EnemyPit) -> String:
	var buf: StreamPeerBuffer = StreamPeerBuffer.new()
	buf.put_32(pit.tick)
	buf.put_float(pit.rivet_pos.x)
	buf.put_float(pit.rivet_pos.y)
	buf.put_float(pit.rivet_hp)
	for e: EnemyAgent in pit.agents:
		e.write_state(buf)
	var ctx: HashingContext = HashingContext.new()
	var res: Error = ctx.start(HashingContext.HASH_SHA256)
	res = ctx.update(buf.data_array)
	assert(res == OK)
	return ctx.finish().hex_encode().substr(0, 16)


## Runs until every enemy is down, Rivet is, or `max_s` passes. Returns the fight's numbers.
static func fight(pit: EnemyPit, dummy: PitDummy, max_s: float) -> Dictionary:
	var max_ticks: int = CombatTuning.ticks(max_s)
	while pit.tick < max_ticks and pit.alive() > 0 and pit.rivet_hp > 0.0:
		dummy.step(pit)
		pit.step()
	var out: Dictionary = {}
	for k: String in pit.stats:
		out[k] = pit.stats[k]
	out["seconds"] = snappedf(pit.tick * SimClock.TICK_DT, 0.01)
	out["cleared"] = pit.alive() == 0
	out["rivet_hp"] = pit.rivet_hp
	out["hit_rate"] = snappedf(pit.stats["shot_hits"] / maxf(pit.stats["shots"], 1.0), 0.001)
	out["digest"] = digest(pit)
	return out


## Runs `run`'s waves against `dummy` until the curve is done or `max_s` passes (Rivet's hp is
## the caller's: set it high to measure the damage a whole curve deals).
static func wave_fight(pit: EnemyPit, dummy: PitDummy, run: WaveRun, max_s: float) -> Dictionary:
	var max_ticks: int = CombatTuning.ticks(max_s)
	while pit.tick < max_ticks and not run.done():
		run.step(pit)
		dummy.step(pit)
		pit.step()
	var out: Dictionary = {"waves": run.report(), "done": run.done()}
	out["seconds"] = snappedf(pit.tick * SimClock.TICK_DT, 0.01)
	out["rivet_damage"] = pit.stats["rivet_damage"]
	out["digest"] = digest(pit)
	var left: Array[String] = []
	for e: EnemyAgent in pit.agents:
		if e.alive():
			var st: String = EnemyAgent.State.keys()[e.state]
			left.append("%s %s %s seen %s sees %s" % [e.arch.id, st, e.pos, e.last_seen, e.sees])
	out["left"] = left
	return out
