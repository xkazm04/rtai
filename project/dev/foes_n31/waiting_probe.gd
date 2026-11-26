extends "res://dev/gauntlet/gauntlet.gd"
## n31 foes: the gauntlet with a read-only observer after every headless tick. Same flags, plus
## --waiting-out=<abs json>: per wave and archetype, how long living members wait to shoot
## (gtai.foes-waiting/1, written before the run result). The run itself is unchanged.

const Tally = preload("res://dev/foes_n31/waiting_tally.gd")
const OUT_FLAG: String = "--waiting-out"
const KNOWN: PackedStringArray = [
	"--seed",
	"--bot",
	"--pick",
	"--waves",
	"--result",
	"--controls",
	"--pick-view",
	"--bot-salt",
	"--pick-filter",
	"--wave-timeout",
	"--waiting-out",
	"--foe-fire",
	"--foe-moves"
]
## Game flags the gauntlet parent does not list: read by the game itself (LaunchArgs), checked here.
const GAME_FLAGS: PackedStringArray = ["--foe-fire", "--foe-moves"]

var _out_path: String = ""
var _tally: Tally


func _invalid_arg(args: ArenaArgs) -> String:
	var rest: ArenaArgs = ArenaArgs.new()
	for flag: String in args.values:
		if GAME_FLAGS.has(flag) and not TakeArgs.valid(flag, args.text(flag)):
			return "%s=%s" % [flag, args.text(flag)]
		if flag != OUT_FLAG and not GAME_FLAGS.has(flag):
			rest.values[flag] = args.values[flag]
	_out_path = args.text(OUT_FLAG)
	if args.has(OUT_FLAG) and not _out_path.is_absolute_path():
		return "%s=%s" % [OUT_FLAG, _out_path]
	return super._invalid_arg(rest)


func _run_headless() -> void:
	_tally = Tally.new(run)
	# The parent's loop, observed after each step; a freeze ends the run the way it does there.
	while not waves.done and session.tick() < RUN_TICKS:
		session.step()
		_tally.observe(session.stage)
		if pilot != null and (session.stage.arena as GauntletCombat).report_bot_freeze():
			_result_path = ""
			_write_waiting()
			var written: bool = _finish()
			get_tree().quit(0 if waves.done and written else 1)
			return
	_write_waiting()
	super._run_headless()


func _write_waiting() -> void:
	if _out_path.is_empty():
		return
	var dir_error: Error = DirAccess.make_dir_recursive_absolute(_out_path.get_base_dir())
	var file: FileAccess = FileAccess.open(_out_path, FileAccess.WRITE) if dir_error == OK else null
	var out: Dictionary = _tally.to_dict()
	out["travel_cause"] = _tally.cause.to_dict()  # b4j: why in-range clear-line foes TRAVEL
	if file == null or not file.store_string(JSON.stringify(out, "  ", true) + "\n"):
		Log.error("foes-waiting", "cannot write %s" % _out_path)
		return
	file.close()
	Log.info("foes-waiting", "wrote %s" % _out_path)
