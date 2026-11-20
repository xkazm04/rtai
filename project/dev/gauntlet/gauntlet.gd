extends Node
## Headless and live gauntlet entry. The dev runner caps unattended runs at 60 simulated seconds.

const KNOWN_FLAGS: PackedStringArray = [
	"--seed", "--bot", "--pick", "--waves", "--result", "--controls"
]
const RUN_TICKS: int = 3600
const BOT_PATH: String = "res://features/gauntlet/bot/gauntlet_bot.gd"

var run: GauntletRun = GauntletRun.new()
var session: ArenaSession
var pilot: GauntletPilot


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var problem: String = _invalid_arg(args)
	if problem != "":
		Log.error("gauntlet", "invalid argument %s" % problem)
		get_tree().quit(2)
		return
	run.seed = args.text("--seed", "0").to_int()
	run.profile = StringName(args.text("--bot", "human"))
	run.controls = StringName(args.text("--controls", "legacy"))
	if args.has("--bot"):
		pilot = _bot()
		if pilot == null:
			Log.error("gauntlet", "cannot instantiate %s as GauntletPilot" % BOT_PATH)
			get_tree().quit(1)
			return
		pilot.configure(run.profile, StringName(args.text("--pick", "random")), run.seed)
	session = ArenaSession.open_with_args(Events, Data, run.seed, pilot, args)
	if pilot != null:
		pilot.bind(run, session)
	var ok: bool = not args.has("--result") or _write_result(args.text("--result"))
	session.close()
	get_tree().quit(0 if ok else 1)


func _bot() -> GauntletPilot:
	if not ResourceLoader.exists(BOT_PATH):
		return GauntletWalker.new()
	var script: GDScript = load(BOT_PATH) as GDScript
	if script == null or not script.can_instantiate():
		return null
	var instance: Object = script.new()
	return instance as GauntletPilot


func _invalid_arg(args: ArenaArgs) -> String:
	for flag: String in args.values:
		var s: String = args.text(flag)
		if not KNOWN_FLAGS.has(flag) or s.is_empty():
			return flag
		var valid: bool = true
		match flag:
			"--seed":
				valid = s.is_valid_int() and s.to_int() >= 0 and s.to_int() <= RngRegistry.SEED_MASK
			"--waves":
				valid = s.is_valid_int() and s.to_int() >= 1
			"--bot":
				valid = s in ["novice", "average", "expert"]
			"--pick":
				valid = s in ["random", "greedy"]
			"--controls":
				valid = s in ["legacy", "wheel"]
			"--result":
				valid = s.is_absolute_path()
		if not valid:
			return "%s=%s" % [flag, s]
	return ""


func _write_result(path: String) -> bool:
	var dir_error: Error = DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE) if dir_error == OK else null
	if file == null or not file.store_string(JSON.stringify(run.to_result(), "  ", true) + "\n"):
		Log.error("gauntlet", "cannot write result to %s" % path)
		return false
	file.close()
	return true
