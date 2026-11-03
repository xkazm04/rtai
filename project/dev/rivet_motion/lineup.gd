extends SceneTree
## rivet-motion: Rivet's proportion lineup launcher (windowed, d3d12). Loads LineupRun at run time
## (a -s main script must not name global classes at parse time) and writes the frames to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/rivet_motion/lineup.gd
##        -- --out=<dir>


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join("../build/evidence/frames")
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--out="):
			printerr("lineup: unknown argument %s" % arg)
			quit(2)
			return
		out = arg.substr(6)
	var node: Node = (load("res://dev/rivet_motion/lineup_run.gd") as GDScript).new()
	node.set("out_dir", out)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("lineup: exit %d" % exit_code)
	quit(exit_code)
