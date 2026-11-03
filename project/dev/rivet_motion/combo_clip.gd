extends SceneTree
## rivet-motion: the claw combo clip launcher (windowed, d3d12; record with --write-movie).
## Loads ComboClipRun at run time (a -s main script must not name global classes at parse time).
## Usage: <godot> --rendering-driver d3d12 --path project --fixed-fps 60 --write-movie <x.avi>
##        -s res://dev/rivet_motion/combo_clip.gd -- --ppm=<32|48> [--weapon=<id>]


func _initialize() -> void:
	var ppm: float = 48.0
	var weapon: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--ppm="):
			ppm = arg.substr(6).to_float()
		elif arg.begins_with("--weapon="):
			weapon = arg.substr(9)
		else:
			printerr("combo_clip: unknown argument %s" % arg)
			quit(2)
			return
	var node: Node = (load("res://dev/rivet_motion/combo_clip_run.gd") as GDScript).new()
	node.set("zoom", ppm / 32.0)
	node.set("weapon", StringName(weapon))
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("play")
	var exit_code: int = code if code is int else 1
	quit(exit_code)
