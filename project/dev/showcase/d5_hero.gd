extends SceneTree
## d5-close hero shot launcher (windowed, d3d12): loads D5HeroRun at run time (a -s main
## script must not name global classes at parse time) and writes the frames to --out.
## Usage: <godot> --rendering-driver d3d12 --path project -s res://dev/showcase/d5_hero.gd
##        -- --out=<dir>   (default: <repo>/build/evidence/frames-d5-hero)
##           --borrow=<dir> (optional: keyed street-life sprites, see D5HeroExtras)
##           --souls (the teal soul trail behind Rivet: off by default, descoped 2026-11-03)
##           --soul=<d5|raw|ghost> (how the souls print, see D5HeroRun._soul_material)
##           --dialogue=<left>,<right> (D5DialogueRun: a dialogue panel with these portraits)
##           --phone=<portrait> (D5DialogueRun: the D5 phone close-up with this portrait)
##           --cam=<x>,<y> (metres: camera below the kill-cam zoom; 0,9.7 = the south roofs)

const KEYS: PackedStringArray = ["soul", "borrow", "dialogue", "phone", "cam", "out"]


func _initialize() -> void:
	var a: Dictionary[String, String] = _args()
	if a.has("?"):
		printerr("d5_hero: unknown argument %s" % a["?"])
		quit(2)
		return
	var out: String = _arg(
		a,
		"out",
		ProjectSettings.globalize_path("res://").path_join("../build/evidence/frames-d5-hero")
	)
	var dialogue: PackedStringArray = _arg(a, "dialogue", "").split(",", false)
	var phone: String = _arg(a, "phone", "")
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
	node.set("borrow_dir", _arg(a, "borrow", ""))
	node.set("soul_mode", _arg(a, "soul", "d5"))
	node.set("show_souls", a.has("souls"))
	var cam: PackedStringArray = _arg(a, "cam", "").split(",", false)
	if cam.size() == 2:
		node.set("hero_cam", Vector2(cam[0].to_float(), cam[1].to_float()) * 32.0)
	root.add_child(node)
	_run(node)


func _arg(a: Dictionary[String, String], key: String, fallback: String) -> String:
	return a[key] if a.has(key) else fallback


## --key=value user args by KEYS; an unknown one lands under "?"
func _args() -> Dictionary[String, String]:
	var a: Dictionary[String, String] = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--souls":
			a["souls"] = ""
			continue
		var key: String = arg.trim_prefix("--").get_slice("=", 0)
		if not arg.begins_with("--") or not arg.contains("=") or not KEYS.has(key):
			a["?"] = arg
			return a
		a[key] = arg.substr(arg.find("=") + 1)
	return a


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("shoot")
	var exit_code: int = code if code is int else 1
	printerr("d5_hero: exit %d" % exit_code)
	quit(exit_code)
