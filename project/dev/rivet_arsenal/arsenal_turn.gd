extends SceneTree
## Film the arena rig at each ground-plane octant.
const KNOWN_FLAGS: PackedStringArray = [
	"--weapon", "--pitch", "--ppm", "--out", "--boss", "--reload-turn", "--sprint-tour"
]
const VIEWS: Dictionary = {"top": "top", "p55": "tilt", "p70": "tilt70"}


func _initialize() -> void:
	call_deferred(&"_start")


func _start() -> void:
	@warning_ignore("unsafe_cast")
	var script_dir: String = (get_script() as Script).resource_path.get_base_dir()
	var args: ArenaArgs = ArenaArgs.parse()
	var entry: String = (
		"arsenal_reload_turn.gd" if args.text("--reload-turn") == "on" else "arsenal_turn_rec.gd"
	)
	if args.text("--sprint-tour") == "on":
		entry = "arsenal_sprint_rec.gd"
	var recorder: Node = (load(script_dir.path_join(entry)) as GDScript).new()
	start_recorder(args, recorder, root, quit)


static func start_recorder(
	args: ArenaArgs, recorder: Node, host: Node, exit_on_error: Callable
) -> void:
	var error: String = configure(args, recorder)
	if not error.is_empty():
		recorder.free()
		host.get_node("Log").call("error", "turn", error)
		exit_on_error.call(2)
		return
	host.add_child(recorder)


static func configure(args: ArenaArgs, recorder: Node) -> String:
	for flag: String in args.values:
		if not KNOWN_FLAGS.has(flag):
			return "unknown argument " + flag
	var pitch: String = args.text("--pitch", "p55")
	var ppm: String = args.text("--ppm", "64")
	var dest: String = args.text("--out")
	if not VIEWS.has(pitch) or ppm not in ["32", "64"] or dest.is_empty():
		return "expected --pitch=p55|p70|top --ppm=32|64 --out=<directory>"
	if args.text("--reload-turn", "off") not in ["off", "on"]:
		return "expected --reload-turn=on|off"
	if args.text("--sprint-tour", "off") not in ["off", "on"]:
		return "expected --sprint-tour=on|off"
	if args.text("--weapon").is_empty():
		return "expected --weapon=<arsenal id>"
	if DirAccess.make_dir_recursive_absolute(dest) != OK:
		return "cannot create " + dest
	var boss: StringName = StringName(args.text("--boss"))
	if boss != &"" and recorder.call(&"has_boss", boss) != true:
		return "unknown boss " + String(boss)
	recorder.set("boss", boss)
	recorder.set("weapon", StringName(args.text("--weapon")))
	recorder.set("out_dir", dest)
	recorder.set("view_id", VIEWS[pitch])
	recorder.set("clip", ppm == "32")
	return ""
