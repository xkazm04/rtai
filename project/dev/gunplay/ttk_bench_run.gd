extends RefCounted
## The TTK bench body (see ttk_bench.gd). Writes gtai.gunplay-ttk/1 JSON: per weapon, per range,
## per target: median time to kill over TRIALS seeds, the kill rate and the hit rate.

const RANGES: Array[float] = [5.0, 10.0, 20.0, 35.0]
const TRIALS: int = 24
## Rivet strafes at his walk speed; humans juke at their run speed (bodies.json).
const RIVET_STRAFE_MPS: float = 4.5

var _trials_n: int = TRIALS


func run() -> int:
	var out_path: String = "user://gunplay-ttk.json"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_path = arg.trim_prefix("--out=")
		elif arg.begins_with("--trials="):
			_trials_n = int(arg.trim_prefix("--trials="))
	var table: WeaponTable = WeaponTable.shipped()
	var bodies: BodyTable = BodyTable.load_default()
	if not table.ok() or not bodies.ok():
		return 1
	var report: Dictionary = {"schema": "gtai.gunplay-ttk/1", "trials": _trials_n, "weapons": {}}
	var targets: Dictionary = {
		"human_still": [table.target_hp[&"human"], bodies.radius(&"human"), 0.0],
		"human_strafe":
		[table.target_hp[&"human"], bodies.radius(&"human"), bodies.run_mps(&"human")],
		"robot_still": [table.target_hp[&"robot"], bodies.radius(&"robot"), 0.0],
	}
	var rivet: Array = [100.0, bodies.radius(&"rivet_base"), RIVET_STRAFE_MPS]
	for id: StringName in table.playable():
		# a charge gun gets a second row held on for the charged round (`<id>:charged`)
		for hold: bool in [false, true] if table.weapon(id).charge_ticks > 0 else [false]:
			var rows: Dictionary = {}
			for key: String in targets:
				var spec: Array = targets[key]
				rows[key] = _ranges(table, id, spec, false, hold)
			rows["enemy_vs_rivet_strafe"] = _ranges(table, id, rivet, true, hold)
			report["weapons"][String(id) + (":charged" if hold else "")] = rows
		Log.info("gunplay", "ttk bench: %s done" % id)
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		Log.error("gunplay", "cannot write %s" % out_path)
		return 1
	if not f.store_string(JSON.stringify(report, "  ", true) + "\n"):
		return 1
	Log.info("gunplay", "ttk bench -> %s" % out_path)
	return 0


func _ranges(
	table: WeaponTable, id: StringName, spec: Array, enemy: bool, hold: bool
) -> Dictionary:
	var out: Dictionary = {}
	for d: float in RANGES:
		var lane: RangeDrill.Lane = RangeDrill.Lane.new()
		lane.weapon = id
		lane.distance_m = d
		lane.target_hp = spec[0]
		lane.target_radius_m = spec[1]
		lane.strafe_mps = spec[2]
		lane.enemy_shooter = enemy
		lane.hold_charge = hold
		out["%d" % int(d)] = _trials(table, lane)
	return out


func _trials(table: WeaponTable, lane: RangeDrill.Lane) -> Dictionary:
	var ttks: Array[float] = []
	var shots: int = 0
	var hits: int = 0
	for i: int in _trials_n:
		var res: RangeDrill.Result = RangeDrill.run(
			table, lane, RngRegistry.new(1000 + i).stream(&"gunplay")
		)
		shots += res.shots
		hits += res.hits
		if res.killed:
			ttks.append(res.ttk_s)
	ttks.sort()
	var median: float = ttks[floori(ttks.size() / 2.0)] if not ttks.is_empty() else -1.0
	return {
		"ttk_median_s": snappedf(median, 0.001),
		"kill_rate": snappedf(float(ttks.size()) / float(_trials_n), 0.01),
		"hit_rate": snappedf(float(hits) / float(maxi(shots, 1)), 0.01),
	}
