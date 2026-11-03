extends SceneTree
## Measures the sticker rim inside the baked crowd atlas (the atlas renders real CutRigs at 48
## px/m): per look, the first WALK cell's opaque area and edge length. Run it once per RIM_K and
## compare areas: rim = area delta / edge length, in atlas px. Windowed (d3d12) only.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/atlas_rim.gd
##        -- --out=<dir> --tag=<name>


func _initialize() -> void:
	var out: String = "user://rim"
	var tag: String = "run"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--tag="):
			tag = arg.substr(6)
	var node: Node = (load("res://dev/showcase/atlas_rim_run.gd") as GDScript).new()
	node.set("out_dir", out)
	node.set("tag", tag)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	quit(exit_code)
