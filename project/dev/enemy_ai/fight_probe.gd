extends SceneTree
## node tools/dev/run.mjs fight_probe --all --seeds=5 --out=<absolute JSON path>
## Like rig_bench, load the world after the -s entry has initialized its autoloads.

const KNOWN_FLAGS: PackedStringArray = [
	"--all", "--encounter", "--seeds", "--out", "--enemy-brain", "--trace", "--horde", "--bot"
]
const RUN_TICKS: int = 2400
const ENCOUNTERS: PackedStringArray = ["city", "pit", "quest1"]

var args: ArenaArgs = ArenaArgs.parse()
var selected: PackedStringArray
var seeds: int = args.text("--seeds", "5").to_int()
var path: String = args.text("--out")


func _initialize() -> void:
	_run.call_deferred()


func _parse() -> bool:
	selected = ENCOUNTERS if args.has("--all") else PackedStringArray([args.text("--encounter")])
	return (
		args.values.keys().all(func(key: String) -> bool: return key in KNOWN_FLAGS)
		and args.has("--all") != args.has("--encounter")
		and args.text("--all") == ""
		and selected[0] in ENCOUNTERS
		and seeds > 0
		and args.text("--seeds", "5").is_valid_int()
		and path.is_absolute_path()
		and path.get_extension().to_lower() == "json"
		and args.text("--enemy-brain", SquadChoice.DEFAULT_BRAIN) in ["guard", "squad", "mixed"]
		and args.text("--trace") == ""
		and args.text("--horde") == ""
		and args.text("--bot", "pit") in ["pit", "gunplay"]
		and (not selected.has("quest1") or not (args.has("--bot") or args.has("--horde")))
	)


func _run() -> void:
	if not _parse():
		printerr("fight_probe: use --all or --encounter=city|pit|quest1, --out=<absolute.json>")
		printerr("--seeds=N --enemy-brain=guard|squad|mixed --trace --horde --bot=pit|gunplay")
		quit(2)
		return
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		printerr("fight_probe: cannot create ", path.get_base_dir())
		quit(1)
		return
	var trace: FileAccess
	if args.has("--trace"):
		trace = FileAccess.open(path.get_basename() + ".ndjson", FileAccess.WRITE)
		if trace == null:
			printerr("fight_probe: cannot create trace beside ", path)
			quit(1)
			return
	quit(0 if _sweep(trace) else 1)


func _sweep(trace: FileAccess) -> bool:
	var script: GDScript = load("res://dev/enemy_ai/fight_probe_trial.gd")
	var runs: Array[Dictionary] = []
	for encounter: String in selected:
		for i: int in seeds:
			var trial: Object = script.new()
			var result: Dictionary = trial.call("run", encounter, 20261103 + i, trace)
			runs.append(result)
			var fields: Array = [encounter, result.seed, result.fight.waves_cleared, result.digest]
			printerr("fight_probe %s %d waves %d digest %s" % fields)
	var complete: bool = runs.all(
		func(r: Dictionary) -> bool: return r.valid and r.objective_reached
	)
	return _write(runs, trace) and complete


func _write(runs: Array[Dictionary], trace: FileAccess) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var report: Dictionary = {
		"schema": "gtai.fight-probe/1",
		"tick_hz": 60,
		"brain": args.text("--enemy-brain", SquadChoice.DEFAULT_BRAIN),
		"horde": args.has("--horde"),
		"bot": args.text("--bot", "pit"),
		"runs": runs,
		"trace": trace.get_path().get_file() if trace != null else null,
		"tick_columns":
		"encounter seed tick hostile_us hostile_steps rivet_x rivet_y hostiles".split(" "),
		"hostile_columns": ["id", "state", "x", "y", "los", "in_cover", "crowded", "fired"]
	}
	if file == null or not file.store_string(JSON.stringify(report, "  ", true, true) + "\n"):
		printerr("fight_probe: cannot write ", path)
		return false
	return true
