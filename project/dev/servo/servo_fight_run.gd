extends SceneTree
## Launcher for the Servo fight graybox (dev/servo/servo_fight_view.gd), windowed d3d12.
## Usage: <godot> --rendering-driver d3d12 --resolution 1280x720 --path project
##   -s res://dev/servo/servo_fight_run.gd -- --out=<dir> [--seconds=20] [--seed=7] [--every=2]
##   [--zoom=1.0 (1.0 = 32 px/m, 1.5 = 48)] [--phase=1..3] [--stand (no dodging)]

const KEYS: Array[String] = ["out", "seconds", "seed", "every", "zoom", "phase", "stand"]


func _initialize() -> void:
	var args: Dictionary[String, String] = {}
	for a: String in OS.get_cmdline_user_args():
		var key: String = a.get_slice("=", 0).trim_prefix("--")
		if not KEYS.has(key):
			printerr("servo_fight: unknown argument %s" % a)
			quit(2)
			return
		args[key] = a.get_slice("=", 1) if a.contains("=") else "1"
	var node: Node = (load("res://dev/servo/servo_fight_view.gd") as GDScript).new()
	node.set("out_dir", _a(args, "out", "user://servo_fight"))
	node.set("ticks", roundi(float(_a(args, "seconds", "20")) * 60.0))
	node.set("every", int(_a(args, "every", "2")))
	node.set("zoom", float(_a(args, "zoom", "1.0")))
	node.set("dodge", not args.has("stand"))
	node.set("fight", _fight(int(_a(args, "seed", "7")), int(_a(args, "phase", "1"))))
	root.add_child(node)
	_run(node)


func _fight(seed_v: int, phase: int) -> Object:
	var spec_script: GDScript = load("res://features/bosses/boss_spec.gd")
	var spec: Object = spec_script.call("shipped", &"servo")
	var reg: Object = (load("res://core/rng/rng_registry.gd") as GDScript).new(seed_v)
	var arena: Object = spec.get("arena")
	var fight_script: GDScript = load("res://features/bosses/boss_fight.gd")
	var f: Object = fight_script.new(
		spec, reg.call("stream", spec.get("rng")), arena.get("boss_at")
	)
	var m: Object = f.get("moves")
	m.call("setup_swarm", reg.call("stream", &"servo_swarm"))
	f.call("start", phase - 1)
	return f


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
	printerr("servo_fight: exit %d" % exit_code)
	quit(exit_code)


func _a(args: Dictionary[String, String], key: String, fallback: String) -> String:
	return args[key] if args.has(key) else fallback
