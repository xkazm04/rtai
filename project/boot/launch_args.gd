extends Node
## LaunchArgs autoload: user args after `--`. Unknown ones are kept for unknown(); the main scene
## (boot/boot.gd) warns about each, so a misspelt flag is not silently ignored.

const KNOWN_FLAGS: PackedStringArray = [
	"--seed",
	"--replay",
	"--record",
	"--devtools",
	"--look",
	"--reduced-motion",
	"--blood",
	"--kill-beat",
	"--gore",
	"--rigs",
	# d7-calls: the old defaults of the owner's 2026-11-05 picks on the main-scene paths (quest 1)
	"--ghosts-free",
	"--rivet-form",
	"--rivet-visor",
	"--rivet-tan",
	"--gun-grey",
	# d7-held: the befores of the hold A/Bs (read straight from the OS args by RigOffClaw / RigGrip)
	"--torch-off-arm",
	"--gun-off-claw",
	# n7-ranged: --feel=off turns the shared hit feel's camera effects off (before clips)
	"--feel",
	# n7-ranged: --react-snap=off drops the hit snap of a reaction family (the electro bolt's before)
	"--react-snap",
	# n7-ranged: --shard-pop=<ticks> the homing shard victim's freeze before the pop (owner call)
	"--shard-pop",
	# n7-ranged: --end-cue=off drops the weapons rows' end_cue (the rocket and nuke blast sound)
	"--end-cue",
	# n7-ranged: --quest-guns=off keeps quest 1's evening gun path (the before of the table guns)
	"--quest-guns",
	# n7-melee: --quest-blade=off gives quest 1 no carried blade (the before); =<id> another one
	"--quest-blade",
	# n7-melee: --hit-cues=off gives melee and ghost hits no sound of their own (the before)
	"--hit-cues",
]

var _values: Dictionary[String, String] = {}
var _unknown: Array[String] = []


func _init() -> void:
	parse(OS.get_cmdline_user_args())


## Parses `--flag` and `--flag=value` pairs; unknown ones are kept for unknown().
func parse(args: PackedStringArray) -> void:
	_values.clear()
	_unknown.clear()
	for arg: String in args:
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			_unknown.append(arg)
			continue
		_values[flag] = arg.substr(flag.length() + 1) if arg.contains("=") else ""


func has(flag: String) -> bool:
	return _values.has(flag)


func value(flag: String) -> String:
	return _values.get(flag, "")


func unknown() -> PackedStringArray:
	return PackedStringArray(_unknown)
