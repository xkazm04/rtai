extends SceneTree
## Same seeds for every brain. Delay loading the session until autoloads are initialized.

const KNOWN_FLAGS: PackedStringArray = ["--seeds", "--out", "--enemy-brain"]
const BRAINS: PackedStringArray = ["guard", "squad", "mixed"]
const WORKLOADS: PackedStringArray = ["city_horde", "pit_horde", "pit_10", "pit_40"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var path: String = args.text("--out")
	var count: String = args.text("--seeds", "5")
	var brain: String = args.text("--enemy-brain", "all")
	if not path.is_absolute_path() or not count.is_valid_int() or count.to_int() <= 0:
		printerr("squad_cost requires --out=<absolute.json> and a positive seed count")
		quit(2)
		return
	if brain != "all" and brain not in BRAINS:
		quit(2)
		return
	var script: GDScript = load("res://dev/enemy_ai/squad_cost_trial.gd")
	var runs: Array[Dictionary] = []
	var valid: bool = true
	for mode: String in BRAINS:
		if brain != "all" and brain != mode:
			continue
		for workload: String in WORKLOADS:
			for i: int in count.to_int():
				var trial: Object = script.new()
				var row: Dictionary = trial.call("run", mode, workload, 20261103 + i)
				runs.append(row)
				valid = valid and row.valid
				printerr("squad_cost %s %s %d valid=%s" % [mode, workload, row.seed, row.valid])
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var doc: Dictionary = {"schema": "gtai.squad-cost/1", "hz": 60, "runs": runs}
	quit(0 if f != null and f.store_string(JSON.stringify(doc, "  ")) and valid else 1)
