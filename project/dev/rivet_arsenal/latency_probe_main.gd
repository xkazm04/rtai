extends SceneTree
## rivet-arsenal: launcher for LatencyProbeRun (latency_probe.gd), loaded at run time so this -s
## main script names no global class at parse time.
## Usage: <godot> --rendering-driver d3d12 --path project
##        -s res://dev/rivet_arsenal/latency_probe_main.gd
##        -- --out=<json>


func _initialize() -> void:
	var node: Node = (load("res://dev/rivet_arsenal/latency_probe.gd") as GDScript).new()
	root.add_child(node)
