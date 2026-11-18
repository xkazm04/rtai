extends SceneTree
## Two fixed-camera takes on an identical input tape: a low crate row, then a high dumpster.

const KNOWN_FLAGS: PackedStringArray = [
	"--ppm", "--view", "--cover", "--no-cover", "--stills", "--out"
]
const FIXED_FPS: int = 60


func _initialize() -> void:
	var course: Node = (load("res://dev/rivet_motion/cover_course_run.gd") as GDScript).new()
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.add_child(course)
	await process_frame
	var result: int = await course.call("play", KNOWN_FLAGS)
	course.free()
	quit(result)
