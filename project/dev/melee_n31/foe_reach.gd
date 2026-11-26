extends SceneTree
## n31 melee 01b, part A: enemy melee reach on Rivet, drawn vs hit. Measures only.
## node tools/dev/run.mjs foe_reach --out=<absolute.json> [--foes=riot_cop,robot_thug] [--step=3]

const KNOWN_FLAGS: PackedStringArray = ["--out", "--foes", "--step"]
const SPEEDS: Array[float] = [3.0, 5.0, 6.75]
const MODES: Array[String] = ["away", "side"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var path: String = args.text("--out")
	var known: bool = args.values.keys().all(func(key: String) -> bool: return key in KNOWN_FLAGS)
	if not known or not path.is_absolute_path():
		printerr("foe_reach needs --out=<absolute.json> [--foes=a,b] [--step=<ticks>]")
		quit(2)
		return
	var trial: GDScript = load("res://dev/melee_n31/foe_reach_trial.gd")
	var runner: Object = trial.new()
	var ids: PackedStringArray = args.text("--foes").split(",", false)
	if ids.is_empty():
		for id: StringName in runner.get("FOES"):
			@warning_ignore("return_value_discarded")
			ids.append(String(id))
	var step: int = maxi(1, args.text("--step", "3").to_int())
	var foes: Array[Dictionary] = []
	for id: String in ids:
		foes.append(_foe(runner, StringName(id), step))
	var out: Dictionary = {
		"schema": "gtai.foe-reach/1",
		"tick_hz": 60,
		"step_ticks": step,
		"speeds_mps": SPEEDS,
		"foes": foes
	}
	var dir_error: Error = DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE) if dir_error == OK else null
	if file == null or not file.store_string(JSON.stringify(out, "  ", true) + "\n"):
		printerr("foe_reach: could not write ", path)
		quit(1)
		return
	file.close()
	quit(0)


func _foe(runner: Object, id: StringName, step: int) -> Dictionary:
	var geo: Dictionary = runner.call("geometry", id)
	var telegraph: int = int(str(geo["telegraph_ticks"]))
	var trials: Array[Dictionary] = []
	for mode: String in MODES:
		for speed: float in SPEEDS:
			for delay: int in range(0, telegraph + 1, step):
				var row: Dictionary = runner.call("run", id, delay, speed, mode, 1)
				row["mode"] = mode
				row["speed_mps"] = speed
				row["delay"] = delay
				trials.append(row)
	geo["trials"] = trials
	return geo
