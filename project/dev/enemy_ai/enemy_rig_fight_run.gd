extends SceneTree
## Launcher for EnemyRigFight (windowed, d3d12; loaded at run time: a -s main script must not name
## global classes at parse time). Frames go to --out; stats.json beside them.
## Usage: <godot> --rendering-driver d3d12 --resolution 1280x720 --path project
##   -s res://dev/enemy_ai/enemy_rig_fight_run.gd -- --out=<dir> [--squad=patrol_cop,robot_thug]
##   [--seconds=20] [--seed=31] [--every=2] [--hp=400] [--human=1] [--fire_m=12] [--rivet_x=-5]
##   [--spots=x:y,x:y (metres, one per squad id; default the east column)]
##   [--aim_lead=0.8 (override enemies.json squad.aim_lead for an A/B clip)]

const KEYS: Array[String] = [
	"out",
	"squad",
	"seconds",
	"seed",
	"every",
	"hp",
	"human",
	"fire_m",
	"rivet_x",
	"spots",
	"aim_lead"
]


func _initialize() -> void:
	var args: Dictionary[String, String] = {}
	for a: String in OS.get_cmdline_user_args():
		var key: String = a.get_slice("=", 0).trim_prefix("--")
		if not KEYS.has(key):
			printerr("enemy_rig_fight: unknown argument %s" % a)
			quit(2)
			return
		args[key] = a.get_slice("=", 1)
	var node: Node = (load("res://dev/enemy_ai/enemy_rig_fight.gd") as GDScript).new()
	node.set("out_dir", _a(args, "out", "user://enemy_rig_fight"))
	root.add_child(node)
	_setup(node, args)
	_run(node)


func _setup(node: Node, args: Dictionary[String, String]) -> void:
	var layout: GDScript = load("res://features/combat/ai/pit_layout.gd")
	var pit: Object = layout.call("build", int(_a(args, "seed", "31")))
	pit.set("rivet_pos", Vector2(float(_a(args, "rivet_x", "-5")), 0.0))
	var ids: Array[StringName] = []
	for id: String in _a(args, "squad", "patrol_cop,robot_thug").split(","):
		ids.append(StringName(id))
	var spots: String = _a(args, "spots", "")
	if spots == "":
		layout.call("squad", pit, ids)
	else:
		var at: PackedVector2Array = PackedVector2Array()
		for xy: String in spots.split(","):
			@warning_ignore("return_value_discarded")
			at.append(Vector2(float(xy.get_slice(":", 0)), float(xy.get_slice(":", 1))))
		layout.call("place", pit, ids, at)
	pit.set("rivet_hp", float(_a(args, "hp", "400")))
	if args.has("aim_lead"):
		var roster: Object = pit.get("roster")
		roster.set("aim_lead", float(args["aim_lead"]))
	var dummy_script: GDScript = load("res://features/combat/ai/pit_dummy.gd")
	var dummy: Object = dummy_script.new(2, pit.get("rivet_pos"))  # PitDummy.Mode.FIGHT
	dummy.set("fire_m", float(_a(args, "fire_m", "12")))
	if _a(args, "human", "1") == "1":
		dummy.set("react_ticks", 15)
		dummy.set("read_frac", 0.7)
		dummy.set("aim_err_deg", 4.0)
		dummy.set("watch_rounds", false)
	node.set("pit", pit)
	node.set("dummy", dummy)
	node.set("every", int(_a(args, "every", "2")))
	node.set("ticks", roundi(float(_a(args, "seconds", "20")) * 60.0))


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	var out: String = node.get("out_dir")
	var f: FileAccess = FileAccess.open(out.path_join("stats.json"), FileAccess.WRITE)
	if f != null:
		@warning_ignore("return_value_discarded")
		f.store_string(JSON.stringify(node.get("stats"), "  ", true))
		f.close()
	printerr("enemy_rig_fight: exit %d" % exit_code)
	quit(exit_code)


func _a(args: Dictionary[String, String], key: String, fallback: String) -> String:
	return args[key] if args.has(key) else fallback
