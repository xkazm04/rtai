extends SceneTree
## rivet-motion: prints PlayerMotion's feel numbers as one JSON object (headless). Loads
## MotionProbeRun at run time (a -s main script must not name global classes at parse time).
## Usage: <godot> --headless --path project -s res://dev/rivet_motion/motion_probe.gd


func _initialize() -> void:
	var probe: RefCounted = (load("res://dev/rivet_motion/motion_probe_run.gd") as GDScript).new()
	var out: Variant = probe.call("run")
	printraw(JSON.stringify(out, "  ", false) + String.chr(10))
	quit(0)
