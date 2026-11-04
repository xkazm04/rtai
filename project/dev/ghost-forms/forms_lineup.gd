extends SceneTree
## ghost-forms: base Rivet beside a ghost form from straight above, look_d4 over the pavement, at
## 32 and 64 px/m (FormsLineupRun). Windowed only (needs a GPU).
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/ghost-forms/forms_lineup.gd
##        -- --out=<dir> [--walk] [--print] [--unfold=<0..1>] [--frames=<n>] [--tag=<name>]


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join("../build/evidence/frames")
	var node: Node = (load("res://dev/ghost-forms/forms_lineup_run.gd") as GDScript).new()
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--walk":
			node.set("walk", true)
		elif arg == "--print":
			node.set("print_parts", true)
		elif arg.begins_with("--unfold="):
			node.set("unfold", float(arg.substr(9)))
		elif arg.begins_with("--frames="):
			node.set("frames", int(arg.substr(9)))
		elif arg.begins_with("--tag="):
			node.set("tag", arg.substr(6))
		elif arg.begins_with("--out="):
			out = arg.substr(6)
		else:
			printerr("forms_lineup: unknown argument %s" % arg)
			quit(2)
			return
	node.set("out_dir", out)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("forms_lineup: exit %d" % exit_code)
	quit(exit_code)
