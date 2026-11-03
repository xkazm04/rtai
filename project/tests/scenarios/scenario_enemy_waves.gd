extends Scenario
## features/combat/ai waves in the pit: every difficulty curve of enemy_waves.json runs against a
## scripted Rivet with a human-like profile (reacts 0.25 s after a tell, notices 70 % of them,
## nails what it sees inside 16 m with 4 degrees of aim error). Judges: the live curve clears
## every wave, waves never overlap (no more alive than the wave's own size), the breather holds
## between waves, the same seed replays to the same digest.
## Planted fault (TST-05): overlapping waves must fail the overlap judge. Also measured (evidence
## for the tell-timing call, not judged): the hit rate on a reacting dodger by aim-lock length.

## The human-like player profile: reacts 0.25 s after a tell, notices 70 % of tells, nails
## with up to 4 degrees of aim error.
const REACT_TICKS: int = 15
const READ_FRAC: float = 0.7
const AIM_ERR_DEG: float = 4.0
const FIRE_M: float = 16.0
const MAX_S: float = 240.0
const LOCKS_S: Array[float] = [0.12, 0.2, 0.3]


func run(_tree: SceneTree) -> String:
	var table: PitWaves = PitWaves.shipped()
	if not table.ok():
		return "enemy_waves.json does not load"
	var ev: Dictionary = {"live_curve": String(table.curve_id), "curves": {}}
	for c: StringName in table.curve_ids():
		ev["curves"][String(c)] = _curve(table, c, false, 31)
	ev["planted_overlap"] = _curve(table, table.curve_id, true, 31)
	ev["replay"] = _curve(table, table.curve_id, false, 31)["digest"]
	ev["breather_s"] = table.breather_ticks * SimClock.TICK_DT
	ev["lock_vs_react"] = _locks()
	Log.info("scenario", "enemy waves: %s" % ev)
	var err: String = write_evidence("enemy-waves.json", ev)
	return err if err != "" else _judge(ev)


func _curve(table: PitWaves, curve: StringName, plant: bool, seed_value: int) -> Dictionary:
	var pit: EnemyPit = PitLayout.build(seed_value)
	pit.rivet_hp = 100000.0
	var dummy: PitDummy = PitDummy.new(PitDummy.Mode.FIGHT, PitLayout.RIVET_START)
	dummy.fire_m = FIRE_M
	dummy.react_ticks = REACT_TICKS
	dummy.read_frac = READ_FRAC
	dummy.aim_err_deg = AIM_ERR_DEG
	var wr: WaveRun = WaveRun.new(table, curve)
	wr.plant_overlap = plant
	return PitLayout.wave_fight(pit, dummy, wr, MAX_S)


func _locks() -> Dictionary:
	var out: Dictionary = {}
	for lock_s: float in LOCKS_S:
		var pit: EnemyPit = PitLayout.build(13, false)
		PitLayout.squad(pit, [&"patrol_cop", &"swat", &"robot_gunner"])
		pit.rivet_hp = 100000.0
		pit.roster.aim_lock_ticks = CombatTuning.ticks(lock_s)
		var dummy: PitDummy = PitDummy.new(PitDummy.Mode.DODGE, PitLayout.RIVET_START)
		dummy.watch_rounds = false
		dummy.react_ticks = REACT_TICKS
		out["%.2f" % lock_s] = PitLayout.fight(pit, dummy, 20.0)["hit_rate"]
	return out


func _judge(ev: Dictionary) -> String:
	var live: Dictionary = ev["curves"][ev["live_curve"]]
	if not live["done"]:
		return "the live curve did not finish in %.0f s: %s" % [MAX_S, live]
	var prev_end: float = -1.0
	for w: Dictionary in live["waves"]:
		if not w["cleared"] or w["max_alive"] > w["enemies"]:
			return "wave not cleared or overlapping: %s" % w
		if prev_end >= 0.0 and w["start_s"] - prev_end < ev["breather_s"] - 0.02:
			return "no breather before %s (prev end %.2f)" % [w, prev_end]
		prev_end = w["start_s"] + w["seconds"]
	var caught: bool = false
	for w: Dictionary in ev["planted_overlap"]["waves"]:
		caught = caught or w["max_alive"] > w["enemies"]
	if not caught:
		return "planted fault (overlapping waves) not caught: %s" % ev["planted_overlap"]
	if ev["replay"] != live["digest"]:
		return "waves not deterministic: %s vs %s" % [ev["replay"], live["digest"]]
	return ""
