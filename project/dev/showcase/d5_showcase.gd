extends SceneTree
## d5-close evidence frames launcher (windowed, d3d12): loads D5ShowcaseRun at run time (a -s main
## script must not name global classes at parse time) and writes the frames to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/d5_showcase.gd
##        -- --out=<dir>   (default: <repo>/build/evidence/frames-d5)
##           --arena        (D5ArenaRun: the cast on King's D5 arena floor)


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join(
		"../build/evidence/frames-d5"
	)
	var run: String = "d5_showcase_run.gd"
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--arena":
			run = "d5_arena_run.gd"
		elif arg.begins_with("--out="):
			out = arg.substr(6)
		else:
			printerr("d5_showcase: unknown argument %s" % arg)
			quit(2)
			return
	var script: GDScript = load("res://dev/showcase/" + run)
	var node: Node = script.new()
	node.set("out_dir", out)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("d5_showcase: exit %d" % exit_code)
	quit(exit_code)
