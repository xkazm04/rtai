extends SceneTree
## d5-close D5 cost launcher (windowed, d3d12): loads D5CostRun at run time (a -s main
## script must not name global classes at parse time) and writes d5-cost.json to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/d5_cost.gd
##        -- --out=<dir>   (default: <repo>/build/evidence/d5-cost)


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join(
		"../build/evidence/d5-cost"
	)
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		else:
			printerr("d5_cost: unknown argument %s" % arg)
			quit(2)
			return
	var script: GDScript = load("res://dev/showcase/d5_cost_run.gd")
	var node: Node = script.new()
	node.set("out_dir", out)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("d5_cost: exit %d" % exit_code)
	quit(exit_code)
