extends RefCounted
## Times the production hostile loop and squad assignment through FightProbeArena.
## Every wave gets the same ten seconds of strafing with the trigger released.

const FIXED_TICKS: int = 600
const WAVES: int = 10
const LIMIT: int = (FIXED_TICKS + 120) * WAVES

var session: ArenaSession
var arena: FightProbeArena
var totals: Array[int] = []
var sums: Dictionary[String, int] = {"routes": 0, "cover": 0, "sight": 0}
var peaks: Dictionary[String, int] = {"routes": 0, "cover": 0, "sight_per_hostile": 0, "alive": 0}
var worst: Dictionary = {}
var cover_spare_min: int = 2147483647
var cover_with_spawns_spare_min: int = 2147483647
var excess: int = 0
var completed: bool = false
var active_ticks: int = 0
var fielded: Dictionary[StringName, int] = {}


func run(brain: String, workload: String, seed: int) -> Dictionary:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var scene: String = "city" if workload == "city_horde" else "pit"
	var opts: ArenaArgs = ArenaArgs.parse(["--enemy-brain=" + brain, "--arena=" + scene])
	session = ArenaSession.open_with_args(bus, data, seed, null, opts)
	arena = FightProbeArena.attach(session.stage.arena)
	var pit: ArenaPit = session.stage.pit
	pit.horde()
	# Exclude the other stations' sparring partners from this pit-only cost measurement.
	session.stage.hooks.clear()
	arena.hostiles.clear()
	arena.squad = pit.standing
	var bot: ArenaPitBot = ArenaPitBot.new(session.stage, session.actions)
	bot.trigger = false
	var fixed: int = workload.get_slice("_", 1).to_int()
	if fixed > 0:
		pit.first_wave = fixed
		pit.max_wave = fixed
	arena.rivet.max_hp *= ArenaPit.HORDE_RIVET_HP
	arena.rivet.hp = arena.rivet.max_hp
	session.world.loop().set_input(bot)
	var wired: bool = _matches(brain, pit)
	if wired:
		_play(pit, fixed)
	if brain == "squad":
		wired = wired and fielded.keys() == [&"contractor"]
	var row: Dictionary = _summary(brain, workload, seed)
	row.composition = pit.squad_mix.duplicate()
	row.valid = wired and completed and excess == 0 and peaks.alive == (fixed if fixed else 10)
	_close(bus, data)
	return row


func _close(bus: EventBus, data: DataStore) -> void:
	session.stage.hooks.clear()
	session.live.cursor_px = Callable()
	if session.stage.vehicles != null:
		session.stage.vehicles.world = null
	session.world.free()
	bus.free()
	data.free()


func _matches(brain: String, pit: ArenaPit) -> bool:
	if brain == "guard":
		return arena.squad_ai == null
	if arena.squad_ai == null:
		return false
	if brain == "mixed":
		return pit.squad_mix.size() > 1
	return pit.squad_mix == [&"contractor"]


func _play(pit: ArenaPit, fixed: int) -> void:
	var wave: int = 0
	for i: int in LIMIT:
		var map: GuardRouteMap = arena.guard_map
		var routes: int = map.searches
		var covers: int = map.cover_searches
		var sights: int = arena.sight_total
		var assignment: int = arena.assignment_us
		session.step()
		var spawns: int = pit.standing.size() if pit.wave != wave else 0
		if pit.wave != wave:
			wave = pit.wave
			for h: Fighter in pit.standing:
				fielded[h.archetype] = fielded.get(h.archetype, 0) + 1
		if pit.wave == 0:
			continue
		var counts: Vector3i = Vector3i(
			map.searches - routes, map.cover_searches - covers, arena.sight_total - sights
		)
		_record(counts, arena.assignment_us - assignment, spawns)
		if arena.stepped > 0 and active_ticks % FIXED_TICKS == 0:
			if fixed > 0 or wave == WAVES:
				completed = true
				return
			for h: Fighter in pit.standing:
				h.hp = 0.0


func _record(counts: Vector3i, assignment: int, spawns: int) -> void:
	var us: int = arena.hostile_us + assignment
	var alive: int = arena.stepped
	totals.append(us)
	active_ticks += int(alive > 0)
	sums.routes += counts.x
	sums.cover += counts.y
	sums.sight += counts.z
	peaks.routes = maxi(peaks.routes, counts.x)
	peaks.cover = maxi(peaks.cover, counts.y)
	peaks.sight_per_hostile = maxi(peaks.sight_per_hostile, arena.peak_sight)
	peaks.alive = maxi(peaks.alive, alive)
	var slots: int = ceili(float(alive) / SquadMind.PLAN_TICKS)
	cover_spare_min = mini(cover_spare_min, slots - counts.y)
	cover_with_spawns_spare_min = mini(cover_with_spawns_spare_min, slots + spawns - counts.y)
	if arena.squad_ai != null:
		excess += int(
			counts.y > slots or counts.x > ArenaSquad.ROUTES_PER_TICK or arena.peak_sight > 2
		)
	if worst.is_empty() or us > worst.total_us:
		worst = {
			"tick": arena.tick,
			"total_us": us,
			"assignment_us": assignment,
			"alive": alive,
			"spawns": spawns,
			"cover_limit": slots,
			"routes": counts.x,
			"cover": counts.y,
			"sight": counts.z,
		}


func _summary(brain: String, workload: String, seed: int) -> Dictionary:
	var ticks: int = totals.size()
	return {
		"brain": brain,
		"workload": workload,
		"seed": seed,
		"ticks": ticks,
		"active_ticks": active_ticks,
		"hostile_steps": arena.costs.size(),
		"fielded": fielded,
		"wave": session.stage.pit.wave,
		"waves_cleared": session.stage.pit.waves_cleared,
		"hostile_us": _stats(arena.costs),
		"tick_us": _stats(totals),
		"routes_per_second": sums.routes * 60.0 / maxi(ticks, 1),
		"cover_per_tick": float(sums.cover) / maxi(ticks, 1),
		"sight_per_hostile": float(sums.sight) / maxi(arena.costs.size(), 1),
		"counts": sums,
		"max": peaks,
		"min_cover_slack": cover_spare_min,
		"min_cover_slack_with_spawns": cover_with_spawns_spare_min,
		"budget_violations": excess,
		"worst_tick": worst,
	}


func _stats(samples: Array[int]) -> Dictionary:
	if samples.is_empty():
		return {}
	samples.sort()
	var total: int = 0
	var histogram: Dictionary[int, int] = {}
	for us: int in samples:
		histogram[us] = histogram.get(us, 0) + 1
		total += us
	return {
		"histogram_us": histogram,
		"mean": float(total) / samples.size(),
		"p99": samples[ceili(0.99 * samples.size()) - 1],
		"max": samples.back(),
	}
