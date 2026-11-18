extends SceneTree
## node tools/dev/run.mjs fight_probe --all --seeds=5 --out=<absolute JSON path>
## Like rig_bench, load the world after the -s entry has initialized its autoloads.

const KNOWN_FLAGS: PackedStringArray = [
	"--all", "--encounter", "--seeds", "--out", "--brain", "--trace"
]
const RUN_TICKS: int = 2400
const ENCOUNTERS: PackedStringArray = ["city", "pit", "quest1"]

var selected: PackedStringArray = []
var seeds: int = 5
var path: String = ""
var brain: String = "old"
var trace_enabled: bool = false


func _initialize() -> void:
	_run.call_deferred()


func _parse() -> bool:
	var args: ArenaArgs = ArenaArgs.parse()
	for key: String in args.values:
		if key not in KNOWN_FLAGS:
			return false
	if args.has("--all") == args.has("--encounter") or args.text("--all") != "":
		return false
	selected = (
		ENCOUNTERS.duplicate()
		if args.has("--all")
		else PackedStringArray([args.text("--encounter")])
	)
	var count: String = args.text("--seeds", "5")
	seeds = count.to_int() if count.is_valid_int() else 0
	path = args.text("--out")
	trace_enabled = args.has("--trace")
	# Production sees these same user args. Enable "squad" here once it exists.
	brain = args.text("--brain", "old")
	return (
		selected[0] in ENCOUNTERS
		and seeds > 0
		and path.is_absolute_path()
		and path.get_extension().to_lower() == "json"
		and brain == "old"
		and args.text("--trace") == ""
	)


func _run() -> void:
	if not _parse():
		printerr(
			"fight_probe: use --all or --encounter=city|pit|quest1, --out=<absolute.json>",
			" [--seeds=<positive integer>] [--brain=old] [--trace]"
		)
		quit(2)
		return
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		printerr("fight_probe: cannot create ", path.get_base_dir())
		quit(1)
		return
	var trace: FileAccess
	if trace_enabled:
		var trace_path: String = path.get_basename() + ".ndjson"
		trace = FileAccess.open(trace_path, FileAccess.WRITE)
		if trace == null:
			printerr("fight_probe: cannot create ", trace_path)
			quit(1)
			return
	var ok: bool = _sweep(trace)
	if trace != null:
		trace.close()
	quit(0 if ok else 1)


func _sweep(trace: FileAccess) -> bool:
	var script: GDScript = load("res://dev/enemy_ai/fight_probe_trial.gd")
	var runs: Array[Dictionary] = []
	var valid: bool = true
	for encounter: String in selected:
		for i: int in seeds:
			var trial: Object = script.new()
			var result: Dictionary = trial.call("run", encounter, 20261103 + i, trace)
			runs.append(result)
			valid = valid and result.valid
			var fields: Array = [encounter, result.seed, result.fight.waves_cleared, result.digest]
			printerr("fight_probe %s %d waves %d digest %s" % fields)
	return _write(runs, trace) and valid


func _write(runs: Array[Dictionary], trace: FileAccess) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var report: Dictionary = {
		"schema": "gtai.fight-probe/1",
		"tick_hz": 60,
		"brain": brain,
		"runs": runs,
		"trace": trace.get_path().get_file() if trace != null else null,
		"tick_columns":
		[
			"encounter",
			"seed",
			"tick",
			"hostile_us",
			"hostile_steps",
			"rivet_x",
			"rivet_y",
			"hostiles"
		],
		"hostile_columns": ["id", "state", "x", "y", "los", "in_cover", "crowded", "fired"]
	}
	if file == null or not file.store_string(JSON.stringify(report, "  ", true, true) + "\n"):
		printerr("fight_probe: cannot write ", path)
		return false
	return true
