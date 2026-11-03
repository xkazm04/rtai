extends SceneTree
## Rivet top-down sprite capture launcher (windowed, d3d12; night lane d4-production): loads
## RivetSpriteRun at run time (a -s main script must not name global classes at parse time).
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/rivet_sprite.gd
##        -- --out=<dir> [--kind=rivet|cop]   writes <out>/<kind>_on_black.png and _on_white.png


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join("../build/evidence/frames")
	var kind: String = "rivet"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg in ["--kind=rivet", "--kind=cop"]:
			kind = arg.substr(7)
		else:
			printerr("rivet_sprite: unknown argument %s" % arg)
			quit(2)
			return
	var script: GDScript = load("res://dev/showcase/rivet_sprite_run.gd")
	var node: Node = script.new()
	node.set("out_dir", out)
	node.set("kind", kind)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("rivet_sprite: exit %d" % exit_code)
	quit(exit_code)
