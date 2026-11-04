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
	"--gore"
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
