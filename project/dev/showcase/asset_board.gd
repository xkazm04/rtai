extends SceneTree
## D4 asset board launcher (windowed, d3d12): loads AssetBoardRun at run time (a -s main script
## must not name global classes at parse time) and writes the frames to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/asset_board.gd
##        -- --out=<dir> [--page=table|extras|corner|roofs|pickups|parts]


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join("../build/evidence/frames")
	var page: String = "table"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--page="):
			page = arg.substr(7)
		else:
			printerr("asset_board: unknown argument %s" % arg)
			quit(2)
			return
	var run: String = "parts_board" if page in ["parts", "pickups", "fx"] else "asset_board"
	var path: String = "res://dev/showcase/%s_run.gd" % run
	var script: GDScript = load(path)
	var node: Node = script.new()
	node.set("out_dir", out)
	node.set("page", page)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("asset_board: exit %d" % exit_code)
	quit(exit_code)
