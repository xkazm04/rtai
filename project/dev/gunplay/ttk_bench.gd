extends SceneTree
## Lane gunplay TTK bench launcher: every playable weapon down range lanes at 5/10/20/35 m against
## a still human, a strafing human, a still robot, plus enemy fire at a strafing Rivet (dodge).
## The runner is loaded at run time (a -s script naming global classes at parse time never starts).
## Usage: <godot> --headless --path project -s res://dev/gunplay/ttk_bench.gd -- --out=<json>


func _initialize() -> void:
	var script: GDScript = load("res://dev/gunplay/ttk_bench_run.gd")
	if script == null or not script.can_instantiate():
		quit(2)
		return
	var runner: Object = script.new()
	var code: Variant = runner.call("run")
	var exit_code: int = code if code is int else 1
	quit(exit_code)
