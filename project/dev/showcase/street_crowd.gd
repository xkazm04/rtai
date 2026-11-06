extends SceneTree
## n8 street: the street crowd board launcher (windowed, d3d12); see StreetCrowdRun.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/street_crowd.gd
##        -- --out=<dir> [--view=<id>] [--ppm=<n>] [--kill=<hit class: light|melee|blast|...>]


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join("../build/evidence/frames")
	var ppm: float = 48.0
	var kill: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--ppm="):
			ppm = arg.substr(6).to_float()
		elif arg.begins_with("--kill="):
			kill = arg.substr(7)
		elif not arg.begins_with("--view="):  # ViewMode reads --view itself
			printerr("street_crowd: unknown argument %s" % arg)
			quit(2)
			return
	var script: GDScript = load("res://dev/showcase/street_crowd_run.gd")
	var node: Node = script.new()
	node.set("out_dir", out)
	node.set("ppm", ppm)
	node.set("kill_class", kill)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("street_crowd: exit %d" % exit_code)
	quit(exit_code)
