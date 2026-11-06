class_name RigBenchRun
extends RefCounted
## The F-09b rig bench: RigStress at 50 and 200 people, 10 s each on the fixed tick, judged
## against STANDARDS section 20 (rig cost: 0.3 ms target, 1 ms hard limit). Writes gtai.bench/1
## JSON (one run per crowd size) and exits 1 when a run breaks the hard limit.
## Run through rig_bench.gd (a -s main script must not name global classes at parse time).

const KNOWN_FLAGS: PackedStringArray = ["--out", "--secs", "--view"]  # --view: ViewMode reads it
const SIZES: Array[int] = [50, 200]


## Returns the exit code: 0 ok, 1 a run broke the hard limit or the write failed, 2 bad args.
func run(tree: SceneTree) -> int:
	var args: Dictionary[String, String] = {"--out": "user://rig_bench.json", "--secs": "10"}
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("rig_bench: unknown argument %s" % arg)
			return 2
		args[flag] = arg.substr(flag.length() + 1)
	var ticks: int = roundi(args["--secs"].to_float() * SimClock.TICK_RATE)
	var runs: Array[Dictionary] = []
	var ok: bool = true
	for people: int in SIZES:
		var m: Dictionary[String, float] = _run(tree, people, ticks)
		var within: bool = m["rigMsP99"] <= RigStress.HARD_MS and m["poolGrown"] == 0.0
		ok = ok and within
		runs.append({"people": people, "metrics": m, "withinHardLimit": within})
	return 0 if _write(args["--out"], runs, ticks) and ok else 1


func _run(tree: SceneTree, people: int, ticks: int) -> Dictionary[String, float]:
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var rigs: CharacterRigs = CharacterRigs.new()
	tree.root.add_child(rigs)
	rigs.setup(World.build_context(bus, data, 9))
	var stress: RigStress = RigStress.new(rigs, people)
	stress.run(ticks)
	var m: Dictionary[String, float] = stress.metrics()
	printerr("rig_bench: %d people %s" % [people, JSON.stringify(m)])
	rigs.free()
	bus.free()
	data.free()
	return m


func _write(path: String, runs: Array[Dictionary], ticks: int) -> bool:
	var res: Dictionary = {
		"schema": "gtai.bench/1",
		"scenario": "rig-stress",
		"mode": "headless" if DisplayServer.get_name() == "headless" else "windowed",
		"debug_build": OS.is_debug_build(),
		"ticks": ticks,
		"budget": {"rigTargetMs": RigStress.TARGET_MS, "rigHardMs": RigStress.HARD_MS},
		"maxFullRigs": CharacterRigs.MAX_FULL,
		"fullRateRigs": CharacterRigs.FULL_RATE,
		"halfRateRigs": CharacterRigs.HALF_RATE,
		"radiusM": CharacterRigs.RADIUS_M,
		"runs": runs,
		"cpu": OS.get_processor_name(),
	}
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return false
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var ok: bool = f != null and f.store_string(JSON.stringify(res, "  "))
	if f != null:
		f.close()
	printerr("rig_bench: -> %s" % path)
	return ok
