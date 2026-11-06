extends SceneTree
## n8 vehicles: the traffic card cost launcher (VehicleCardsCostRun does the work in frames).
## The runner is loaded at run time (like rig_bench.gd): a -s main script that names global classes
## at parse time never starts.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/bench/vehicle_cards_cost.gd
##        -- --view=tilt70 --out=<json path> [--counts=32,64,128,256] [--frames=240]


func _initialize() -> void:
	var script: GDScript = load("res://dev/bench/vehicle_cards_cost_run.gd")
	var runner: Node = script.new()
	root.add_child.call_deferred(runner)
