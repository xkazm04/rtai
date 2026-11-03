extends SceneTree
## Measures the sticker rim (the cream halo under every rig part) in screen px: one rig alone on
## flat asphalt, drawn with and without its halos, at 32/48/64/128 px/m. Windowed (d3d12).
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/rim_measure.gd
##        -- --out=<dir> [--tag=before]


func _initialize() -> void:
	var out: String = "user://rim"
	var tag: String = "run"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--tag="):
			tag = arg.substr(6)
	var node: Node = (load("res://dev/showcase/rim_measure_run.gd") as GDScript).new()
	node.set("out_dir", out)
	node.set("tag", tag)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	quit(exit_code)
