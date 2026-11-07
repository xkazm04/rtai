extends SceneTree
## A quest 1 autosave written on one OS and resumed on another (handheld E14; dev tool, dev/ is
## not exported). `write` plays quest 1 on a scripted input tape (none with `idle`), autosaves
## through the real Save engine into <dir>, resumes it at once and runs <after> more ticks; `read`
## resumes the slot folder another machine wrote and runs the same ticks. Both print the hashes.
## Usage: godot --headless --path project -s res://dev/save_cross.gd -- [--seed=7]
##   --save-cross=write,<abs dir>[,<ticks 1800>,<after 600>[,idle]]   or   --save-cross=read,<dir>


func _initialize() -> void:
	var script: GDScript = load("res://dev/save_cross_run.gd") as GDScript
	if script == null or not script.can_instantiate():
		printerr("save_cross: does not compile")
		quit(2)
		return
	var body: Object = script.new()
	var rc: int = body.call("run")
	quit(rc)
