extends SceneTree
## Frame time of the slice on the city (dev-only, never shipped): boot/quest1.tscn in a real
## window, vsync off, quest 1 fast-forwarded headlessly-in-place to `--from` (default: the
## Dock 9 fight) by the scripted pad, then `--frames` frames at one sim tick per frame, each
## frame's wall time recorded. Writes p50/p95/p99/max ms as JSON to `--out`. Take it under
## C:/Users/kazda/kiro/gtai-day-d5/bench.lock; the machine is shared, so label it CONTENDED.
## Usage: godot --rendering-driver d3d12 --path project --resolution 1920x1080
##   -s res://dev/bench/quest1_frames.gd -- --out=<file.json> [--from=5800] [--frames=1200]

const KNOWN_FLAGS: PackedStringArray = ["--out", "--from", "--frames"]
const BODY: String = "res://dev/bench/quest1_frames_run.gd"


func _initialize() -> void:
	var values: Dictionary[String, String] = {}
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("quest1_frames: unknown argument %s" % arg)
			quit(2)
			return
		values[flag] = arg.substr(flag.length() + 1)
	if values.get("--out", "") == "":
		printerr("quest1_frames: needs --out=<file.json>")
		quit(2)
		return
	var script: GDScript = load(BODY) as GDScript
	if script == null or not script.can_instantiate():
		printerr("quest1_frames: %s does not compile" % BODY)
		quit(1)
		return
	var run: Node = script.new()
	run.set("out_path", values["--out"])
	var from: String = values.get("--from", "5800")
	var count: String = values.get("--frames", "1200")
	run.set("from_tick", from.to_int())
	run.set("frames", count.to_int())
	root.add_child(run)
