class_name FightProbeSample
extends RefCounted
## One trace line per observed tick, including ticks in the gap between waves.
## Actors are sampled between hostile decisions and ballistics. The digest uses end-of-tick state.

var arena: FightProbeArena
var walls: ArenaWalls = ArenaWalls.new()
var cells: StageCells
var trace: FileAccess
var encounter: String
var world_seed: int
var observing: bool = false
var ticks: int = 0
var hostile_ticks: int = 0
var visible: int = 0
var covered: int = 0
var crowded: int = 0
var peak_pairs: int = 0
var total_pairs: int = 0
var distance_m: float = 0.0
var states: Dictionary[String, int] = {}
var archetype_states: Dictionary[StringName, Dictionary] = {}
var flankers: Dictionary[int, bool] = {}
var flank_angles: Dictionary[int, bool] = {}
var rows: Array[Array] = []
var rivet_pos: Vector2
var hash_ctx: HashingContext = HashingContext.new()
var ok: bool = true


func _init(a: FightProbeArena) -> void:
	arena = a
	ok = hash_ctx.start(HashingContext.HASH_SHA256) == OK


func sample() -> void:
	rows.clear()
	rivet_pos = arena.rivet.pos
	if not observing:
		return
	var living: Array[Fighter] = []
	var positions: Array[Vector2] = []
	for h: Fighter in arena.squad:
		if h.alive():
			living.append(h)
			positions.append(h.pos)
	var neighbours: PackedInt32Array = FightProbeGeometry.neighbours(positions)
	var mean_dir: Vector2 = FightProbeGeometry.mean_bearing(arena.rivet.pos, positions)
	var ends: int = 0
	for i: int in living.size():
		ends += neighbours[i]
		_actor(living[i], neighbours[i] > 0, mean_dir)
	var pairs: int = ends >> 1
	total_pairs += pairs
	peak_pairs = maxi(peak_pairs, pairs)


func _actor(h: Fighter, near: bool, mean_dir: Vector2) -> void:
	var at: Vector2 = arena.rivet.pos
	var los: bool = _visible(h, at)
	var cover: bool = FightProbeGeometry.in_cover(h.pos, los, walls.boxes, cells)
	var state: String = arena.states.get(h.id, "idle")
	var fired: bool = arena.fired.has(h.id)
	var bearing: Vector2 = h.pos - at
	if fired and FightProbeGeometry.flanking(bearing, mean_dir):
		flankers[h.id] = true
		flank_angles[posmod(roundi(rad_to_deg(bearing.angle())), 360)] = true
	hostile_ticks += 1
	visible += int(los)
	covered += int(cover)
	crowded += int(near)
	distance_m += bearing.length()
	states[state] = states.get(state, 0) + 1
	var id: StringName = h.archetype if h.archetype != &"" else &"contractor"
	var histogram: Dictionary = archetype_states.get_or_add(id, {})
	histogram[state] = histogram.get(state, 0) + 1
	if trace != null:
		rows.append([h.id, state, h.pos.x, h.pos.y, los, cover, near, fired])


func _visible(h: Fighter, target: Vector2) -> bool:
	if arena.guard_map != null:
		return arena.guard_map.clear_line(h.pos, target)
	# scenario_quest_collect_call has no walls or solid cells.
	return (
		not walls.blocks(h.pos, target)
		and (cells == null or cells.swept_clear(h.pos, target, h.radius_m))
	)


func digest_tick() -> void:
	var buf: StreamPeerBuffer = StreamPeerBuffer.new()
	buf.put_32(arena.tick)
	buf.put_32(arena.hostiles.size())
	for h: Fighter in arena.hostiles:
		buf.put_32(h.id)
		buf.put_float(h.pos.x)
		buf.put_float(h.pos.y)
		buf.put_double(h.hp)
	ok = hash_ctx.update(buf.data_array) == OK and ok


func finish_tick() -> void:
	ticks += 1
	if trace == null:
		return
	var record: Array = [encounter, world_seed, arena.tick, arena.hostile_us, arena.stepped]
	record.append_array([rivet_pos.x, rivet_pos.y, rows])
	ok = trace.store_line(JSON.stringify(record, "", false, true)) and ok


func summary() -> Dictionary:
	var n: float = float(hostile_ticks)
	return {
		"hostile_ticks": hostile_ticks,
		"los_share": visible / n if n else null,
		"cover_share": covered / n if n else null,
		"crowded_share": crowded / n if n else null,
		"mean_distance_m": distance_m / n if n else null,
		"pairs_peak": peak_pairs,
		"pairs_mean": float(total_pairs) / ticks if ticks else null,
		"state_histogram": states,
		"states_by_archetype": archetype_states,
		"distinct_flank_angles_deg": flank_angles.size(),
		"distinct_flanking_shooters": flankers.size(),
	}


func cost() -> Dictionary:
	var samples: Array[int] = arena.costs
	samples.sort()
	var n: int = samples.size()
	var total: int = 0
	for us: int in samples:
		total += us
	return {
		"label": "CONTENDED",
		"assignment_us": arena.assignment_us,
		"assignment_ticks": arena.assignment_ticks,
		"hostile_steps": n,
		"total_us": total,
		"mean_us_per_tick": float(total) / ticks if ticks else null,
		"mean_us_per_hostile": float(total) / n if n else null,
		"p99_us_per_hostile": samples[ceili(n * 0.99) - 1] if n else null,
		"max_us_per_hostile": samples.back() if n else null
	}
