extends Node
## The movie clock is 60 frames/s. Each change of sim state is exactly one shipped tick.
## Film-frame numbers run from 1; --stills uses the same clock as the movie and both arms.

const KNOWN_FLAGS: PackedStringArray = [
	"--move", "--off", "--ppm", "--stills", "--out", "--kerf-glide"
]
const FIXED_FPS: int = 60
const NEEDS_WINDOW: bool = true
const FRAMES: int = 960
const RESOLUTION: Vector2i = Vector2i(1920, 1080)

var take: MoveFilmTake
var screen: MoveFilmView
var move: StringName
var off: bool
var ppm: int
var stills: Array[int] = []
var out_dir: String
var frame: int = 0
var next_step: int = 1


func _ready() -> void:
	set_process(false)
	var args: ArenaArgs = ArenaArgs.parse()
	move = StringName(args.text("--move"))
	off = args.has("--off")
	var zoom: String = args.text("--ppm", "32")
	if not MoveFilmTake.WEAPONS.has(move) or zoom not in ["32", "64"]:
		_fail("supply a move id and --ppm=32 or 64")
		return
	ppm = zoom.to_int()
	out_dir = args.text("--out")
	if args.has("--stills") and not _parse_stills(args.text("--stills")):
		_fail("use --stills=1,2,... (film frames in 1..960) and an absolute --out directory")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = RESOLUTION
	ViewMode.select("combo")
	RenderingServer.set_default_clear_color(Ink.CREAM)
	process_priority = -1000
	if not _open(false):
		_fail("could not build the take")
		return
	set_process(true)


func _parse_stills(raw: String) -> bool:
	if raw == "" or not out_dir.is_absolute_path():
		return false
	for part: String in raw.split(","):
		if not part.is_valid_int() or part.to_int() < 1 or part.to_int() > FRAMES:
			return false
		stills.append(part.to_int())
	stills.sort()
	return DirAccess.make_dir_recursive_absolute(out_dir) == OK


func _open(second: bool) -> bool:
	take = MoveFilmTake.new()
	if not take.open(move, off, second):
		return false
	screen = MoveFilmView.new()
	add_child(screen)
	next_step = frame
	return screen.open(take, ppm)


func _close() -> void:
	if screen != null:
		screen.free()
		screen = null
	if take != null:
		take.close()
		take = null


func _process(_delta: float) -> void:
	frame += 1
	if frame == 481 and move != MoveTable.ARMOUR_CRACK:
		_close()
		if not _open(true):
			_fail("could not build the second take")
			return
	var divisor: int = _pace()
	take.film_frame = frame
	if frame >= next_step:
		take.advance()
		next_step = frame + divisor
	screen.update_readout(divisor)
	if frame in [5, 490]:
		var at: Vector2 = screen.screen_point(take.subject.pos)
		if not _framed(at):
			_fail("subject or camera outside the requested framing")
			return
	if frame in stills or frame == FRAMES:
		await RenderingServer.frame_post_draw
		if frame in stills and not _save_frame():
			_fail("could not save the 1920x1080 game viewport")
			return
		if frame == FRAMES or (not stills.is_empty() and frame == stills[-1]):
			set_process(false)
			_finish.call_deferred()


func _framed(subject_px: Vector2) -> bool:
	var size_px: Vector2 = get_viewport().get_visible_rect().size
	var ppm_x: float = screen.screen_point(Vector2.RIGHT).x - screen.screen_point(Vector2.ZERO).x
	var pitch: float = ViewMode.shared().pitch_deg
	take.mark(
		"subject screen %s, viewport %s, %.2f px/m, tilt %.1f" % [subject_px, size_px, ppm_x, pitch]
	)
	return (
		Vector2i(size_px) == RESOLUTION
		and is_equal_approx(ppm_x, float(ppm))
		and is_equal_approx(pitch, 70.0)
		and Rect2(Vector2.ZERO, RESOLUTION).grow(-100.0).has_point(subject_px)
	)


func _pace() -> int:
	match move:
		MoveTable.SHORT_CIRCUIT:
			return 2 if take.elapsed < 180 and not take.second else 1
		MoveTable.ARMOUR_CRACK:
			return 2 if take.first_stomp < 0 else 1
		MoveTable.BLINK_BEHIND:
			if take.second:
				return 5
			return 4 if take.elapsed >= 88 else 1
		MoveTable.OVERKILL:
			return 8 if take.second else 4
	return 1


func _save_frame() -> bool:
	var img: Image = get_viewport().get_texture().get_image()
	if img == null or img.get_size() != RESOLUTION:
		return false
	var file: String = "%s-%s-%d-f%04d.png" % [move, "off" if off else "on", ppm, frame]
	take.mark(file)
	return img.save_png(out_dir.path_join(file)) == OK


func _fail(message: String) -> void:
	set_process(false)
	Log.error("move-film", message)
	get_tree().quit(2)


func _finish() -> void:
	_close()
	# Allow the renderer to release its last references before the scene tree shuts down.
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit()


func _exit_tree() -> void:
	_close()
