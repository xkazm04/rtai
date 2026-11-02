extends SceneTree
## F-09b evidence frames launcher (windowed, d3d12): loads RigShowcaseRun at run time (a -s main
## script must not name global classes at parse time) and writes the frames to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/rig_showcase.gd
##        -- --out=<dir>   (default: <repo>/build/evidence/frames)
##        [--motion]       the LOD motion strip instead (rig_motion_run.gd)


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join("../build/evidence/frames")
	var runner: String = "res://dev/showcase/rig_showcase_run.gd"
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--motion":
			runner = "res://dev/showcase/rig_motion_run.gd"
			continue
		if not arg.begins_with("--out="):
			printerr("rig_showcase: unknown argument %s" % arg)
			quit(2)
			return
		out = arg.substr(6)
	var script: GDScript = load(runner)
	var node: Node = script.new()
	node.set("out_dir", out)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("rig_showcase: exit %d" % exit_code)
	quit(exit_code)
