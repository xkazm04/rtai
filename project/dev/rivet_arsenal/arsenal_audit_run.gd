extends SceneTree
## Headless -s entry. Load the audit after startup so its renderer classes can resolve autoloads.
## Paths may be absolute or relative to the repository root. Both outputs are optional.

const KNOWN_FLAGS: PackedStringArray = ["--out", "--txt"]
const SYMBOLS: Dictionary[String, String] = {"ok": ".", "HOLE": "X", "n/a": "-"}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var log_sink: Node = root.get_node("Log")
	var args: Dictionary[String, String] = ArenaArgs.parse().values
	for key: String in args:
		if not KNOWN_FLAGS.has(key) or args[key].is_empty():
			log_sink.call("error", "arsenal", "invalid argument " + key)
			quit(2)
			return
	var script: GDScript = load("res://dev/rivet_arsenal/arsenal_audit.gd")
	if script == null or not script.can_instantiate():
		quit(1)
		return
	var audit: Object = script.new()
	var matrix: Dictionary = audit.call("build")
	var table: String = _format(matrix, script.get_script_constant_map())
	log_sink.call("info", "arsenal", "\n" + table)
	var success: bool = true
	if args.has("--out"):
		success = _write(args["--out"], JSON.stringify(matrix, "  ", true) + "\n")
	if args.has("--txt"):
		success = _write(args["--txt"], table) and success
	var missing: Dictionary = matrix.missing_resources
	for path: String in missing:
		log_sink.call("error", "arsenal", "HOLE " + path)
	var problems: Array[String] = matrix.table_errors
	for problem: String in problems:
		log_sink.call("error", "arsenal", problem)
	if not success:
		log_sink.call("error", "arsenal", "could not write requested output")
	quit(0 if success and problems.is_empty() and missing.is_empty() else 1)


func _format(matrix: Dictionary, spec: Dictionary) -> String:
	var lines: Array[String] = ["Rivet arsenal    . ok    X HOLE    - n/a", ""]
	var header: String = "weapon".rpad(17) + "pitch".rpad(7)
	for col: String in spec.COLUMNS:
		header += col.rpad(col.length() + 2)
	lines.append(header + "holes")
	var weapons: Dictionary = matrix.weapons
	var ids: Array = weapons.keys()
	ids.sort()
	for id: String in ids:
		for pitch: String in spec.PITCHES:
			var first: bool = pitch == "top"
			var line: String = (id if first else "").rpad(17) + pitch.rpad(7)
			for col: String in spec.COLUMNS:
				var status: String = matrix.weapons[id][pitch][col].status
				line += SYMBOLS[status].rpad(col.length() + 2)
			lines.append(
				line + str(matrix.holes_per_weapon[id]) if first else line.strip_edges(false, true)
			)
	lines.append("Total holes  %d" % matrix.total_holes)
	return "\n".join(lines) + "\n"


func _write(arg: String, data: String) -> bool:
	var path: String = (
		arg
		if arg.is_absolute_path()
		else ProjectSettings.globalize_path("res://").path_join("../" + arg).simplify_path()
	)
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		return false
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	return file != null and file.store_string(data)
