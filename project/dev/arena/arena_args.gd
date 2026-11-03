class_name ArenaArgs
extends RefCounted
## The dev arena's own args after `--` (read here, not added to the shared LaunchArgs autoload):
## --ppm=<n>, --bot=<station>, --shot=<png>, --shot-tick=<n>, --telemetry=<json>, --panel (open
## the tuning panel), --tune=<key>:<value> (one live change at tick 300, for the panel proof).

var values: Dictionary[String, String] = {}


static func parse(args: PackedStringArray = OS.get_cmdline_user_args()) -> ArenaArgs:
	var a: ArenaArgs = ArenaArgs.new()
	for arg: String in args:
		var flag: String = arg.get_slice("=", 0)
		a.values[flag] = arg.substr(flag.length() + 1) if arg.contains("=") else ""
	return a


func text(flag: String, fallback: String = "") -> String:
	return values.get(flag, fallback)


func has(flag: String) -> bool:
	return values.has(flag)


func number(flag: String, fallback: float) -> float:
	return values[flag].to_float() if values.has(flag) else fallback
