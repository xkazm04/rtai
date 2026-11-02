extends SceneTree
## d5-close hero shot launcher (windowed, d3d12): loads D5HeroRun at run time (a -s main
## script must not name global classes at parse time) and writes the frames to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/d5_hero.gd
##        -- --out=<dir>   (default: <repo>/build/evidence/frames-d5-hero)
##           --borrow=<dir> (optional: keyed street-life sprites, see D5HeroExtras)
##           --soul=<d5|raw|ghost> (how the souls print, see D5HeroRun._soul_material)


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join(
		"../build/evidence/frames-d5-hero"
	)
	var borrow: String = ""
	var soul_mode: String = "d5"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--soul="):
			soul_mode = arg.substr(7)
		elif arg.begins_with("--borrow="):
			borrow = arg.substr(9)
		elif arg.begins_with("--out="):
			out = arg.substr(6)
		else:
			printerr("d5_hero: unknown argument %s" % arg)
			quit(2)
			return
	var script: GDScript = load("res://dev/showcase/d5_hero_run.gd")
	var node: Node = script.new()
	node.set("out_dir", out)
	node.set("borrow_dir", borrow)
	node.set("soul_mode", soul_mode)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("d5_hero: exit %d" % exit_code)
	quit(exit_code)
