extends SceneTree
## The merge rehearsal for arena stations: loads every station file in a folder (all lanes'
## files together, as after the merge), builds each station's hook, and resolves every tuning
## knob against the tables in this tree. Writes a JSON report; exit 1 when a file is skipped,
## a named hook does not build, or a knob does not resolve.
## Usage: godot --headless --path project -s res://dev/arena/stations_check.gd
##   -- [--dir=<abs dir, default res://data/tables/arena_stations>] --out=<abs json>

const CHECKER: String = "res://dev/arena/stations_report.gd"


func _initialize() -> void:
	var dir: String = "res://data/tables/arena_stations"
	var out: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--dir="):
			dir = arg.substr(6)
		elif arg.begins_with("--out="):
			out = arg.substr(6)
	# Loaded at run time: the checker's classes name autoloads, not yet known when this compiles.
	var checker: GDScript = load(CHECKER) as GDScript
	var report: Dictionary = checker.call(&"check", dir)
	if out != "":
		@warning_ignore("return_value_discarded")
		DirAccess.make_dir_recursive_absolute(out.get_base_dir())
		var f: FileAccess = FileAccess.open(out, FileAccess.WRITE)
		if f != null:
			@warning_ignore("return_value_discarded")
			f.store_string(JSON.stringify(report, "  ", true) + "\n")
			f.close()
	var problems: Array = report["problems"]
	var bad: int = problems.size()
	printerr("stations check: %d stations, %d problems" % [report["count"], bad])
	quit(1 if bad > 0 else 0)
