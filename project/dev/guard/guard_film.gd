extends Node
## One 10 s take at a time. Captures the displayed viewport after each simulated tick and writes
## its telemetry beside the frames. --still=N advances the same take and saves just that tick.

const KNOWN_FLAGS: PackedStringArray = ["--out", "--beat", "--ppm", "--controls", "--still"]
const FIXED_FPS: int = 60
const NEEDS_WINDOW: bool = true
const TICKS: int = 600
const RESOLUTION: Vector2i = Vector2i(1920, 1080)

var film_set: GuardFilmSet = GuardFilmSet.new()
var beats: GuardFilmBeats
var captions: GuardFilmCaptions = GuardFilmCaptions.new()
var out_dir: String
var still: int
var ppm: int
var rows: Array[Dictionary] = []
var capturing: bool = false


func _ready() -> void:
	set_process(false)
	var args: ArenaArgs = ArenaArgs.parse()
	out_dir = args.text("--out")
	var beat: String = args.text("--beat", "guard")
	ppm = int(args.number("--ppm", 32.0))
	still = int(args.number("--still", 0.0))
	if not out_dir.is_absolute_path() or beat not in ["guard", "rocket", "wall", "wheel"]:
		_fail("use --out=<absolute directory> and --beat=guard|rocket|wall|wheel")
		return
	if ppm not in [32, 64] or still < 0 or still > TICKS:
		_fail("--ppm must be 32 or 64 and --still must be in 1..600 when used")
		return
	if DirAccess.make_dir_recursive_absolute(out_dir) != OK:
		_fail("cannot create " + out_dir)
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = RESOLUTION
	LaunchArgs.parse(["--controls=" + args.text("--controls", "wheel")])
	ViewMode.select("combo")
	RenderingServer.set_default_clear_color(Ink.CREAM)
	film_set.build(beat)
	film_set.view_on(self, ppm)
	beats = GuardFilmBeats.new(film_set, beat)
	add_child(captions)
	process_priority = -1000
	set_process(true)


func _process(_delta: float) -> void:
	if capturing:
		return
	capturing = true
	beats.advance()
	var row: Dictionary = beats.sample()
	rows.append(row)
	captions.show_tick(beats.beat, row)
	await RenderingServer.frame_post_draw
	if still == 0 or still == beats.tick:
		var img: Image = get_viewport().get_texture().get_image()
		if img == null or img.get_size() != RESOLUTION:
			_fail("expected the full 1920x1080 game viewport")
			return
		var path: String = out_dir.path_join("frame-%04d.png" % beats.tick)
		if img.save_png(path) != OK:
			_fail("could not save " + path)
			return
	if beats.tick == TICKS or beats.tick == still:
		_finish()
	else:
		capturing = false


func _finish() -> void:
	set_process(false)
	var f: FileAccess = FileAccess.open(out_dir.path_join("telemetry.json"), FileAccess.WRITE)
	if f == null:
		_fail("could not write telemetry")
		return
	var data: Dictionary = {
		"beat": beats.beat,
		"controls": ControlsMode.id(),
		"ppm": ppm,
		"pitch": ViewMode.shared().pitch_deg,
		"art": ViewMode.shared().art,
		"rows": rows
	}
	if not f.store_string(JSON.stringify(data)):
		_fail("could not save telemetry")
		return
	f.close()
	Log.info("guard_film", "%s: tick %d, %d px/m, %s" % [beats.beat, beats.tick, ppm, out_dir])
	EnemyRounds.reset()
	get_tree().quit()


func _fail(message: String) -> void:
	set_process(false)
	Log.error("guard_film", message)
	get_tree().quit(2)
