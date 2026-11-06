extends SceneTree
## Clip recorder entry for the slice (boot/quest1.tscn). The work is in quest1_clip_rec.gd, loaded
## after the autoloads exist (a script compiled with the -s main script cannot see them).
## Needs a window (the headless display has no renderer); dev-only, never shipped.
## Usage: godot --path project --resolution 1920x1080 -s res://dev/frames/quest1_clip.gd
##   -- --out=<abs dir> [--ppm=32] [--stills=<tick,tick,...>] (stills only: no clip, no title)
##   [--save=<abs file>] (the game writes its beat checkpoints there)
##   [--continue] (with --save: press Continue on the title, save the first frames, quit)
##   [--rigs] (rivet-arsenal: the quest drawn on the cast rigs, Quest1Game._dev_rigs)
##   [--cam=fight] (rivet-arsenal: the camera leans toward the cop Rivet fights, render only)
##   [--ticks=<from>-<to>] (rivet-arsenal: clip only these ticks, e.g. Dock 9's 13600-13840)
##   [--quest-guns=off] (n7-ranged: the evening gun path, the before of the table guns)
##   [--weapon-fx=shapes] (n7-ranged it16: no weapon-art cells, e.g. the rifle's dashes: the before)

const KNOWN_FLAGS: PackedStringArray = [
	"--out",
	"--ppm",
	"--stills",
	"--save",
	"--continue",
	"--rigs",
	"--cam",
	"--ticks",
	"--quest-guns",
	"--weapon-fx"
]
const RECORDER: String = "res://dev/frames/quest1_clip_rec.gd"
const COUNTER: String = "res://tests/support/error_counter.gd"

## Counts engine/script errors during the capture; finish() exits 1 when there were any.
var _errors: Logger = null


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
	var counter: GDScript = load(COUNTER) as GDScript
	if counter != null and counter.can_instantiate():
		var made: Object = counter.new()
		if made is Logger:
			_errors = made
			OS.add_logger(_errors)
	var script: GDScript = load(RECORDER) as GDScript
	if script == null or not script.can_instantiate():
		printerr("quest1_clip: %s does not compile" % RECORDER)
		quit(1)
		return
	var rec: Node = script.new()
	rec.set("out_dir", out)
	_configure(rec, values)
	root.add_child(rec)


func _configure(rec: Node, values: Dictionary[String, String]) -> void:
	var ppm: String = values.get("--ppm", "32")
	rec.set("px_per_m", ppm.to_float())
	var stills: Array[int] = []
	var ticks: String = values.get("--stills", "")
	for t: String in ticks.split(",", false):
		stills.append(t.to_int())
	rec.set("stills", stills)
	rec.set("save_path", values.get("--save", ""))
	rec.set("press_continue", values.has("--continue"))
	rec.set("fight_cam", values.get("--cam", "") == "fight")
	var window: String = values.get("--ticks", "")
	if window.contains("-"):
		var from: int = window.get_slice("-", 0).to_int()
		rec.set("tick_window", Vector2i(from, window.get_slice("-", 1).to_int()))


## Called by the recorder when it is done: 0, or 1 when any engine/script error was logged.
func finish() -> void:
	var count: int = 0
	if _errors != null:
		var n: Variant = _errors.call(&"count")
		count = n if n is int else 0
		OS.remove_logger(_errors)
	if count > 0:
		printerr("quest1_clip: %d engine/script error(s) during the capture" % count)
	quit(1 if count > 0 else 0)
