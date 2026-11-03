extends SceneTree
## d5-close walk shimmer launcher (windowed, d3d12): loads D5WalkRun at run time (a -s main
## script must not name global classes at parse time) and writes the frames to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/d5_walk.gd
##        -- --out=<dir>   (default: <repo>/build/evidence/frames-d5)
##           --zoom=<z>   (camera zoom, 1.0 = 32 px/m; default 2.0 = 64 px/m; crop scales)


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join(
		"../build/evidence/frames-d5-walk"
	)
	var zoom: float = 2.0
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--zoom=") and arg.substr(7).is_valid_float():
			zoom = arg.substr(7).to_float()
		else:
			printerr("d5_walk: unknown argument %s" % arg)
			quit(2)
			return
	var script: GDScript = load("res://dev/showcase/d5_walk_run.gd")
	var node: Node = script.new()
	node.set("out_dir", out)
	node.set("walk_zoom", zoom)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("d5_walk: exit %d" % exit_code)
	quit(exit_code)
