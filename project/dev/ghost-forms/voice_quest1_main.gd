extends SceneTree
## ghost-forms (dev): entry for VoiceQuest1 (voice_quest1.gd, loaded after the autoloads exist).
## Needs a window. Usage: godot --path project --resolution 1280x800 --screen 0
##   -s res://dev/ghost-forms/voice_quest1_main.gd -- --out=<abs dir>

const WORKER: String = "res://dev/ghost-forms/voice_quest1.gd"


func _initialize() -> void:
	var out: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
	if out == "" or DirAccess.make_dir_recursive_absolute(out) != OK:
		printerr("voice_quest1: needs --out=<writable dir>")
		quit(2)
		return
	var script: GDScript = load(WORKER) as GDScript
	if script == null or not script.can_instantiate():
		printerr("voice_quest1: %s does not compile" % WORKER)
		quit(1)
		return
	var worker: Node = script.new()
	worker.set("out_dir", out)
	root.add_child(worker)
