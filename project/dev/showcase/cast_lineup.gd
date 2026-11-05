extends SceneTree
## n5-cast: the cast lineup frames launcher (windowed, d3d12); see CastLineupRun.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/cast_lineup.gd
##        -- --out=<dir> [--walk] [--crowd] [--road] [--form=<RivetPlan form id>]
##        [--warm=<RivetPlan.d5_warm>]


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join("../build/evidence/frames")
	var walk: bool = false
	var flags: Dictionary[String, bool] = {"--crowd": false, "--road": false}
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--walk":
			walk = true
		elif flags.has(arg):
			flags[arg] = true
		elif arg.begins_with("--form="):
			RivetPlan.form = StringName(arg.substr(7))  # before the pool builds Rivet's plan
		elif arg.begins_with("--warm="):
			RivetPlan.d5_warm = float(arg.substr(7))
		elif arg.begins_with("--out="):
			out = arg.substr(6)
		else:
			printerr("cast_lineup: unknown argument %s" % arg)
			quit(2)
			return
	var script: GDScript = load("res://dev/showcase/cast_lineup_run.gd")
	var node: Node = script.new()
	node.set("out_dir", out)
	node.set("walk", walk)
	node.set("crowd", flags["--crowd"])
	node.set("road", flags["--road"])
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("cast_lineup: exit %d" % exit_code)
	quit(exit_code)
