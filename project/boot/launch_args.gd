extends Node
## LaunchArgs autoload: user args after `--`. Unknown args fail loudly (TST-03).

const KNOWN_FLAGS: PackedStringArray = ["--seed", "--replay", "--devtools"]

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
