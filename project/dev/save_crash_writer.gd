extends SceneTree
## Crash-test writer (dev only): autosaves a ~100 KB body in a tight loop into --root=<dir> until
## it is killed. tools/tests/save_crash.mjs kills it at random moments and checks the slots with an
## independent reader. The loop is loaded at run time so the Log autoload exists when it compiles.
## Usage: godot --headless --path project -s res://dev/save_crash_writer.gd -- --root=<abs dir>


func _initialize() -> void:
	var root: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--root="):
			root = arg.substr(7)
	var loop: GDScript = load("res://dev/save_crash_loop.gd") as GDScript
	if root == "" or loop == null:
		quit(2)
		return
	@warning_ignore("unsafe_method_access")
	loop.new().call("run", root)
