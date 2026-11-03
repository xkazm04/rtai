extends SceneTree
## d5-cast: King on the cutout rig, arena frames (windowed, d3d12). Loads KingShowcaseRun at run
## time (a -s main script must not name global classes at parse time).
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/king_showcase.gd
##        -- --out=<dir>   (default: <repo>/build/evidence/frames-king)
##           --rivet-form=<base|night> (RivetPlan.FORMS: night = the pre-2026-11-03 scale)
##           --king-size=<k> (KingPlan size_k for this run; default KingPlan.SIZE_K)


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join(
		"../build/evidence/frames-king"
	)
	var form: String = "base"
	var king_size: float = -1.0
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--rivet-form="):
			form = arg.substr(13)
		elif arg.begins_with("--king-size="):
			king_size = arg.substr(12).to_float()
		elif arg.begins_with("--out="):
			out = arg.substr(6)
		else:
			printerr("king_showcase: unknown argument %s" % arg)
			quit(2)
			return
	var script: GDScript = load("res://dev/showcase/king_showcase_run.gd")
	var node: Node = script.new()
	node.set("rivet_form", StringName(form))
	node.set("out_dir", out)
	if king_size > 0.0:
		node.set("king_size", king_size)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot_king")
	var exit_code: int = code if code is int else 1
	printerr("king_showcase: exit %d" % exit_code)
	quit(exit_code)
