extends SceneTree
## Weapon-art lineup launcher (windowed, d3d12): loads WeaponLineupRun at run time (a -s main
## script must not name global classes at parse time) and writes the frames to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/weapon_art/weapon_lineup.gd
##        -- --out=<dir>   (default: <repo>/build/evidence/weapon-art)


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join(
		"../build/evidence/weapon-art"
	)
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--out="):
			printerr("weapon_lineup: unknown argument %s" % arg)
			quit(2)
			return
		out = arg.substr(6)
	var script: GDScript = load("res://dev/weapon_art/weapon_lineup_run.gd")
	if script == null or not script.can_instantiate():
		printerr("weapon_lineup: runner does not compile")
		quit(2)
		return
	var node: Node = script.new()
	node.set("out_dir", out)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("weapon_lineup: exit %d" % exit_code)
	quit(exit_code)
