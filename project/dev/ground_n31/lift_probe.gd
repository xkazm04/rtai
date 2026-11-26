extends SceneTree
## n31 ground lift probe: Rivet walks and/or sprints through the 8 octants in the real arena and
## every captured tick is saved three times (full, no drop shadow, no Rivet) so a reader
## (tools/ground/lift/lift.py) can separate body and shadow pixels from delivered frames.
## --ppm (32|64) is read by ArenaGame itself (the arena camera scale).
const KNOWN_FLAGS: PackedStringArray = ["--weapon", "--pitch", "--gaits", "--out", "--ppm"]
const VIEWS: Dictionary = {"p55": "tilt", "p70": "tilt70"}


func _initialize() -> void:
	call_deferred(&"_start")


func _start() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var error: String = _check(args)
	if not error.is_empty():
		root.get_node("Log").call("error", "lift", error)
		quit(2)
		return
	@warning_ignore("unsafe_cast")
	var dir: String = (get_script() as Script).resource_path.get_base_dir()
	var rec: Node = (load(dir.path_join("lift_rec.gd")) as GDScript).new()
	rec.set("weapon", StringName(args.text("--weapon", "hands")))
	rec.set("out_dir", args.text("--out"))
	rec.set("view_id", VIEWS[args.text("--pitch", "p70")])
	rec.set("clip", false)
	rec.set("gaits", args.text("--gaits", "move,sprint").split(","))
	root.add_child(rec)


static func _check(args: ArenaArgs) -> String:
	for flag: String in args.values:
		if not KNOWN_FLAGS.has(flag):
			return "unknown argument " + flag
	if not VIEWS.has(args.text("--pitch", "p70")):
		return "expected --pitch=p55|p70"
	for gait: String in args.text("--gaits", "move,sprint").split(","):
		if gait not in ["move", "sprint"]:
			return "expected --gaits=move,sprint"
	if args.text("--ppm", "32") not in ["32", "64"]:
		return "expected --ppm=32|64"
	var dest: String = args.text("--out")
	if dest.is_empty() or DirAccess.make_dir_recursive_absolute(dest) != OK:
		return "expected --out=<writable directory>"
	return ""
