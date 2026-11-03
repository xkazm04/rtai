extends SceneTree
## rivet-motion: the motion course launcher (walk, strafe, sprint, roll; windowed, d3d12; record
## with --write-movie). Loads MotionCourseRun at run time (a -s main script must not name
## global classes at parse time).
## Usage: <godot> --rendering-driver d3d12 --path project --fixed-fps 60 --write-movie <x.avi>
##        -s res://dev/rivet_motion/motion_course.gd -- --ppm=<32|48>


func _initialize() -> void:
	var ppm: float = 48.0
	for arg: String in OS.get_cmdline_user_args():
		if not arg.begins_with("--ppm="):
			printerr("motion_course: unknown argument %s" % arg)
			quit(2)
			return
		ppm = arg.substr(6).to_float()
	var node: Node = (load("res://dev/rivet_motion/motion_course_run.gd") as GDScript).new()
	node.set("zoom", ppm / 32.0)
	root.add_child(node)
	_run(node)


func _run(node: Node) -> void:
	await process_frame
	var code: Variant = await node.call("play")
	var exit_code: int = code if code is int else 1
	quit(exit_code)
