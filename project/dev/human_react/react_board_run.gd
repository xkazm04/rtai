extends SceneTree
## Launcher for ReactBoard (windowed, d3d12; loaded at run time: a -s main script must not name
## global classes at parse time). Usage:
##   <godot> --rendering-driver d3d12 --resolution 1280x720 --path project
##     -s res://dev/human_react/react_board_run.gd -- --out=<dir>
##     [--zoom=1] [--every=2] [--only=<n>] [--board=street]
## --board=street plays StreetBoard (a crowd's reaction to a kill) instead of the board.

const KEYS: Array[String] = ["out", "zoom", "every", "only", "board"]


func _initialize() -> void:
	var args: Dictionary[String, String] = {}
	for a: String in OS.get_cmdline_user_args():
		var key: String = a.get_slice("=", 0).trim_prefix("--")
		if not KEYS.has(key):
			printerr("react_board: unknown argument %s" % a)
			quit(2)
			return
		args[key] = a.get_slice("=", 1)
	var board: String = "street_board" if args.get("board", "") == "street" else "react_board"
	var node: Node = (load("res://dev/human_react/%s.gd" % board) as GDScript).new()
	node.set("out_dir", args.get("out", "user://react_board"))
	node.set("zoom", str(args.get("zoom", "1")).to_float())
	node.set("every", str(args.get("every", "2")).to_int())
	node.set("only", str(args.get("only", "-1")).to_int())
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("react_board: exit %d" % exit_code)
	quit(exit_code)
