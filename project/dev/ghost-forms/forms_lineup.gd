extends SceneTree
## ghost-forms: base Rivet beside a ghost form from straight above, look_d4 over the pavement, at
## 32 and 64 px/m (FormsLineupRun). Windowed only (needs a GPU).
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/ghost-forms/forms_lineup.gd
##        -- --out=<dir> [--walk] [--print] [--morph [--hold=<ticks>] [--reduced-motion]]
##        [--zoom=<1|2>] [--full] [--unfold=<0..1>] [--frames=<n>] [--tag=<name>]


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join("../build/evidence/frames")
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var run: String = "forms_morph_run" if args.has("--morph") else "forms_lineup_run"
	var node: Node = (load("res://dev/ghost-forms/%s.gd" % run) as GDScript).new()
	for arg: String in args:
		if arg == "--morph":
			pass
		elif arg == "--full":
			node.set("full", true)
		elif arg == "--reduced-motion":
			node.set("reduced_motion", true)
		elif arg.begins_with("--zoom="):
			node.set("_zoom_base", float(arg.substr(7)))
		elif arg.begins_with("--hold="):
			node.set("hold_ticks", int(arg.substr(7)))
		elif arg == "--raw":
			node.set("raw", true)
		elif arg == "--dent":
			node.set("dent", true)
		elif arg == "--walk":
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
