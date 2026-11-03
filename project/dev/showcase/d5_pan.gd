extends SceneTree
## d5-close car-camera pan shimmer launcher (windowed, d3d12): loads D5PanRun at run time (a -s main
## script must not name global classes at parse time) and writes the frames to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/d5_pan.gd
##        -- --out=<dir>   (default: <repo>/build/evidence/frames-d5)
##           --anchor=<x>,<y> (metres: the crop centre; 9.7,-8.5 = the mural roof)


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join(
		"../build/evidence/frames-d5-pan"
	)
	var anchor: PackedStringArray = PackedStringArray()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--anchor="):
			anchor = arg.substr(9).split(",")
		else:
			printerr("d5_pan: unknown argument %s" % arg)
			quit(2)
			return
	var script: GDScript = load("res://dev/showcase/d5_pan_run.gd")
	var node: Node = script.new()
	node.set("out_dir", out)
	if anchor.size() == 2:
		node.set("anchor_m", Vector2(anchor[0].to_float(), anchor[1].to_float()))
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("d5_pan: exit %d" % exit_code)
	quit(exit_code)
