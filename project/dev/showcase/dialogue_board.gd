extends SceneTree
## n8-hud dialogue board launcher (windowed, d3d12): loads DialogueBoardRun at run time (a -s main
## script must not name global classes at parse time) and writes the stills to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/dialogue_board.gd
##        -- --out=<abs dir> [--size=1920x1080]


func _initialize() -> void:
	var out: String = "user://"
	var size: Vector2i = Vector2i(1920, 1080)
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
		elif arg.begins_with("--size="):
			var wh: PackedStringArray = arg.substr(7).split("x")
			size = Vector2i(wh[0].to_int(), wh[1].to_int())
		else:
			printerr("dialogue_board: unknown argument %s" % arg)
			quit(2)
			return
	var script: GDScript = load("res://dev/showcase/dialogue_board_run.gd")
	var node: Node = script.new()
	node.set("out_dir", out)
	node.set("size_px", size)
	root.add_child(node)
