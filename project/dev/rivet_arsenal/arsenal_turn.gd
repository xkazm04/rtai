extends SceneTree
## Film the arena rig at each ground-plane octant.
const KNOWN_FLAGS: PackedStringArray = ["--weapon", "--pitch", "--ppm", "--out"]
const VIEWS: Dictionary = {"top": "top", "p55": "tilt", "p70": "tilt70"}


func _initialize() -> void:
	call_deferred(&"_start")


func _start() -> void:
	@warning_ignore("unsafe_cast")
	var script_dir: String = (get_script() as Script).resource_path.get_base_dir()
	var recorder: Node = (load(script_dir.path_join("arsenal_turn_rec.gd")) as GDScript).new()
	var error: String = configure(ArenaArgs.parse(), recorder)
	if not error.is_empty():
		recorder.free()
		root.get_node("Log").call("error", "turn", error)
		quit(2)
		return
	root.add_child(recorder)


static func configure(args: ArenaArgs, recorder: Node) -> String:
	for flag: String in args.values:
		if not KNOWN_FLAGS.has(flag):
			return "unknown argument " + flag
	var pitch: String = args.text("--pitch", "p55")
	var ppm: String = args.text("--ppm", "64")
	var dest: String = args.text("--out")
	if not VIEWS.has(pitch) or ppm not in ["32", "64"] or dest.is_empty():
		return "expected --pitch=p55|p70|top --ppm=32|64 --out=<directory>"
	if args.text("--weapon").is_empty():
		return "expected --weapon=<arsenal id>"
	if DirAccess.make_dir_recursive_absolute(dest) != OK:
		return "cannot create " + dest
	recorder.set("weapon", StringName(args.text("--weapon")))
	recorder.set("out_dir", dest)
	recorder.set("view_id", VIEWS[pitch])
	recorder.set("clip", ppm == "32")
	return ""
