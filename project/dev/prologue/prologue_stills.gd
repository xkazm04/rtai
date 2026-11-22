extends Node
## Capture the real prologue viewport after the yard and Dale's first-kill ticks render.

const KNOWN_FLAGS: PackedStringArray = ["--bot", "--film-dir", "--seed", "--view"]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60

var _game: PrologueGame
var _out: String
var _yard_saved: bool = false
var _saving: bool = false


func _ready() -> void:
	process_priority = 60
	_game = $Prologue as PrologueGame
	_out = ArenaArgs.parse().text("--film-dir")
	if DisplayServer.get_name() == "headless" or not LaunchArgs.has("--bot"):
		Log.error("prologue-film", "stills require a rendered --bot run")
		get_tree().quit(2)
		return
	if not _out.is_absolute_path() or DirAccess.make_dir_recursive_absolute(_out) != OK:
		Log.error("prologue-film", "--film-dir must be a writable absolute directory")
		get_tree().quit(2)


func _process(_dt: float) -> void:
	if _saving:
		return
	var tick: int = _game.stage.tick
	if tick == 300 and not _yard_saved:
		_saving = true
		_capture.call_deferred("yard-t0300", tick)
	elif _game.encounter.dale_died == tick:
		_saving = true
		_capture.call_deferred("dale-first-kill-t%d" % tick, tick)


func _capture(stem: String, tick: int) -> void:
	await RenderingServer.frame_post_draw
	var path: String = _out.path_join(stem + ".png")
	var frame: Image = get_viewport().get_texture().get_image()
	if _game.stage.tick != tick or frame == null or frame.is_empty():
		Log.error("prologue-film", "frame unavailable for tick %d" % tick)
		get_tree().quit(1)
		return
	var err: Error = frame.save_png(path)
	if err != OK:
		Log.error("prologue-film", "%s: %s" % [path, error_string(err)])
		get_tree().quit(1)
		return
	Log.info("prologue-film", "tick %d, %s px, %s" % [tick, frame.get_size(), path])
	_saving = false
	if tick == 300:
		_yard_saved = true
	else:
		get_tree().quit(0 if _yard_saved else 1)
