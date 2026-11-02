extends SceneTree
## Frame grabber entry for quest 1 (collect-call). The work is in frame_grabber.gd, loaded
## after the autoloads exist (a script compiled with the -s main script cannot see them).
## Needs a window (the headless display has no renderer); dev-only, never shipped.
## Usage: godot --path project --resolution 1920x1080 -s res://dev/frames/collect_call_frames.gd
##   -- --out=<abs dir>

const KNOWN_FLAGS: PackedStringArray = ["--out"]
const GRABBER: String = "res://dev/frames/frame_grabber.gd"


func _initialize() -> void:
	var out: String = ""
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("collect_call_frames: unknown argument %s" % arg)
			quit(2)
			return
		out = arg.substr(flag.length() + 1)
	if out == "" or DirAccess.make_dir_recursive_absolute(out) != OK:
		printerr("collect_call_frames: needs --out=<writable dir>")
		quit(2)
		return
	var script: GDScript = load(GRABBER) as GDScript
	if script == null or not script.can_instantiate():
		printerr("collect_call_frames: %s does not compile" % GRABBER)
		quit(1)
		return
	var grabber: Node = script.new()
	grabber.set("out_dir", out)
	root.add_child(grabber)
