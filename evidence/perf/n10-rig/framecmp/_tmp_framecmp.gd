extends SceneTree
## scratch: load a Node runner that renders one RigStress frame (never committed to project/).


func _initialize() -> void:
	var script: GDScript = load("res://dev/bench/_tmp_framecmp_run.gd")
	var runner: Node = script.new()
	root.add_child(runner)
