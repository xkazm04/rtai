extends SceneTree
## Clip recorder entry for the slice (boot/quest1.tscn). The work is in quest1_clip_rec.gd, loaded
## after the autoloads exist (a script compiled with the -s main script cannot see them).
## Needs a window (the headless display has no renderer); dev-only, never shipped.
## Usage: godot --path project --resolution 1920x1080 -s res://dev/frames/quest1_clip.gd
##   -- --out=<abs dir> [--ppm=32] [--stills=<tick,tick,...>] (stills only: no clip, no title)

const KNOWN_FLAGS: PackedStringArray = ["--out", "--ppm", "--stills"]
const RECORDER: String = "res://dev/frames/quest1_clip_rec.gd"


func _initialize() -> void:
	var values: Dictionary[String, String] = {}
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("quest1_clip: unknown argument %s" % arg)
			quit(2)
			return
		values[flag] = arg.substr(flag.length() + 1)
	var out: String = values.get("--out", "")
	if out == "" or DirAccess.make_dir_recursive_absolute(out) != OK:
		printerr("quest1_clip: needs --out=<writable dir>")
		quit(2)
		return
	var script: GDScript = load(RECORDER) as GDScript
	if script == null or not script.can_instantiate():
		printerr("quest1_clip: %s does not compile" % RECORDER)
		quit(1)
		return
	var rec: Node = script.new()
	rec.set("out_dir", out)
	var ppm: String = values.get("--ppm", "32")
	rec.set("px_per_m", ppm.to_float())
	var stills: Array[int] = []
	var ticks: String = values.get("--stills", "")
	for t: String in ticks.split(",", false):
		stills.append(t.to_int())
	rec.set("stills", stills)
	root.add_child(rec)
