extends SceneTree
## The F-09b rig bench launcher: RigStress at 50 and 200 people, judged against STANDARDS
## section 20, written as gtai.bench/1 JSON (rig_bench_run.gd). The runner is loaded at run time
## (like bake_city.gd): a -s main script that names global classes at parse time never starts.
## Usage: <godot> --headless --path project -s res://dev/bench/rig_bench.gd -- --out=<json path>


func _initialize() -> void:
	var script: GDScript = load("res://dev/bench/rig_bench_run.gd")
	var runner: Object = script.new()
	var code: Variant = runner.call("run", self)
	var exit_code: int = code if code is int else 1
	quit(exit_code)
