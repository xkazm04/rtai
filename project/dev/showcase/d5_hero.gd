extends SceneTree
## d5-close hero shot launcher (windowed, d3d12): loads D5HeroRun at run time (a -s main
## script must not name global classes at parse time) and writes the frames to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/d5_hero.gd
##        -- --out=<dir>   (default: <repo>/build/evidence/frames-d5-hero)
##           --borrow=<dir> (optional: keyed street-life sprites, see D5HeroExtras)
##           --soul=<d5|raw|ghost> (how the souls print, see D5HeroRun._soul_material)
##           --dialogue=<left>,<right> (D5DialogueRun: a dialogue panel with these portraits)
##           --phone=<portrait> (D5DialogueRun: the D5 phone close-up with this portrait)


func _initialize() -> void:
	var out: String = ProjectSettings.globalize_path("res://").path_join(
		"../build/evidence/frames-d5-hero"
	)
	var borrow: String = ""
	var soul_mode: String = "d5"
	var dialogue: PackedStringArray = PackedStringArray()
	var phone: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--soul="):
			soul_mode = arg.substr(7)
		elif arg.begins_with("--borrow="):
			borrow = arg.substr(9)
		elif arg.begins_with("--dialogue="):
			dialogue = arg.substr(11).split(",")
		elif arg.begins_with("--phone="):
			phone = arg.substr(8)
		elif arg.begins_with("--out="):
			out = arg.substr(6)
		else:
			printerr("d5_hero: unknown argument %s" % arg)
			quit(2)
			return
	var ui: bool = dialogue.size() == 2 or phone != ""
	var run: String = "d5_dialogue_run.gd" if ui else "d5_hero_run.gd"
	var script: GDScript = load("res://dev/showcase/" + run)
	var node: Node = script.new()
	if dialogue.size() == 2:
		node.set("left_name", dialogue[0])
		node.set("right_name", dialogue[1])
	if ui:
		node.set("phone_name", phone)
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
