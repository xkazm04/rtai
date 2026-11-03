extends SceneTree
## d5-cast: the cast's plan-view footprint, measured from the rigs themselves (headless, no GPU).
## Each body plan stands in its idle stance facing +x for 90 ticks; the union of its visible part
## rects (world px, 32 px/m) gives length (along facing) x width in metres. Prints one JSON line.
## Loads RigFootprintRun at run time (a -s main script must not name global classes at parse time).
## Usage: <godot> --headless --path project -s res://dev/bench/rig_footprint.gd


func _initialize() -> void:
	var script: GDScript = load("res://dev/bench/rig_footprint_run.gd")
	var out: Variant = script.call("measure", root)
	printerr("rig_footprint: " + JSON.stringify(out))
	quit(0)
