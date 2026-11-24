extends Node
## Seek the seed-7 pilot before the first draw, then expose one tick per movie frame.

const KNOWN_FLAGS: PackedStringArray = [
	"--yard-dressing", "--place", "--tick", "--frames", "--ppm", "--still"
]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60
const SIZE: Vector2i = Vector2i(1920, 1080)

var _game: PrologueGame
var _view: PrologueView
var _at: Vector2
var _first: int
var _frames: int
var _ppm: int
var _count: int = 0
var _still: String
var _commander: bool


func _ready() -> void:
	set_process(false)
	var args: ArenaArgs = ArenaArgs.parse()
	var problem: String = _read_args(args)
	if problem != "":
		_fail(problem)
		return
	_still = args.text("--still")
	if args.has("--still") and not _still.is_absolute_path():
		_fail("use an absolute PNG path for the still")
		return
	if not Engine.get_write_movie_path().is_empty():
		var width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
		var height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
		if Vector2i(width, height) != SIZE:
			_fail("use a 1920x1080 movie capture profile")
			return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	_start_game(args)


func _start_game(args: ArenaArgs) -> void:
	LaunchArgs.parse(["--bot", "--seed=7", "--yard-dressing=" + args.text("--yard-dressing")])
	ViewMode.select("tilt70")
	_game = preload("res://boot/prologue/prologue.tscn").instantiate()
	add_child(_game)
	if _game.world == null:
		_fail("prologue failed to start")
		return
	_game.world.set_process(false)
	for child: Node in _game.get_children():
		if child is PrologueView:
			_view = child as PrologueView
	YardCamera.hide_hud(_view)
	_commander = args.text("--place") == "commander"
	if not _commander:
		_at = YardCamera.center(_game.stage.plan as PrologueYard, args.text("--place"), _first)
	_view.px_per_m = float(_ppm)
	# Run the ordinary view first (including the ringing phone), then lock the print passes.
	_view.set_process(false)
	while _game.world.context().clock.tick() <= _first:
		if _past_end():
			_fail("requested range extends past the end card")
			return
		_game.world.loop().step()
	process_priority = -100
	set_process(true)


func _read_args(args: ArenaArgs) -> String:
	for key: String in args.values:
		if key not in KNOWN_FLAGS:
			return "unknown option " + key
	if DisplayServer.get_name() == "headless" or get_window().size != SIZE:
		return "use a 1920x1080 window"
	if (
		args.text("--yard-dressing") not in ["plain", "torn_line", "line_fire"]
		or args.text("--place") not in ["gate", "mid", "harbor", "commander"]
	):
		return "choose a yard dressing and gate, mid, harbor or commander"
	for key: String in ["--tick", "--frames", "--ppm"]:
		if not args.text(key).is_valid_int():
			return "expected an integer for " + key
	_first = args.text("--tick").to_int()
	_frames = args.text("--frames").to_int()
	_ppm = args.text("--ppm").to_int()
	if _first < 0 or _frames < 1 or _ppm not in [32, 64]:
		return "use a nonnegative start, positive frame count and 32 or 64 px/m"
	return ""


func _process(_dt: float) -> void:
	if _count > 0:
		_game.world.loop().step()
	if _past_end() or _game.stage.tick != _first + _count:
		_fail("requested tick %d is unavailable at %d" % [_first + _count, _game.stage.tick])
		return
	_view._process(SimClock.TICK_DT)
	_view.print_stage.kick_px = Vector2.ZERO
	if _commander:
		var boss: Fighter = _game.encounter.battle.formation.boss
		if boss == null or not boss.alive():
			_fail("commander is absent at tick %d" % _game.stage.tick)
			return
		_at = boss.pos
	YardCamera.place(_view, _at, _ppm)
	_view.print_stage.lights.step(_game.stage.tick, _view.print_stage.world_px)
	_view.blood.step(_game.stage.tick, _view.print_stage.world_px)
	_count += 1
	if _count == _frames:
		_finish()


func _past_end() -> bool:
	var end: int = _game.encounter.street.end_tick
	return end >= 0 and _first + _frames - 1 > end + PrologueStreet.END_TICKS


func _finish() -> void:
	set_process(false)
	if _still != "":
		await RenderingServer.frame_post_draw
		var frame: Image = get_viewport().get_texture().get_image()
		if frame == null or frame.get_size() != SIZE or frame.save_png(_still) != OK:
			_fail("could not save " + _still)
			return
	Log.info("yard-film", "%d frames, ticks %d..%d" % [_count, _first, _game.stage.tick])
	get_tree().quit()


func _fail(message: String) -> void:
	Log.error("yard-film", message)
	get_tree().quit(2)
