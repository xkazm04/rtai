extends SceneTree
## Fixed-tick arena and city course. Capture the rendered framebuffer after the named tick.

const KNOWN_FLAGS: PackedStringArray = [
	"--ppm", "--view", "--vault", "--no-vault", "--stills", "--out"
]
const FIXED_FPS: int = 60


func _initialize() -> void:
	var course: Node = (load("res://dev/rivet_motion/vault_course_run.gd") as GDScript).new()
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.add_child(course)
	await process_frame
	var result: int = await course.call("play", KNOWN_FLAGS)
	quit(result)
