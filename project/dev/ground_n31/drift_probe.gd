extends Node
## n31-07: the prologue on the pilot bot, one sim tick per frame as prologue_film. Every drawn
## frame logs the camera transform and PrintStage.world_px (ticks.jsonl); on the capture ticks
## the centre crop is saved as played (`_a`) and again on a held tick with the look off (`_b`,
## the floor geometry without the print), so tools/ground/drift can phase the print against it.
## --clip=<ids>: `64` films at 64 px/m; `play` keeps the project stretch (canvas_items, as a
## player sees it) instead of the film tools' CONTENT_SCALE_MODE_DISABLED.
## --result=<abs dir> is the output directory.

const KNOWN_FLAGS: PackedStringArray = ["--bot", "--clip", "--result", "--seed"]
const NEEDS_WINDOW: bool = true
const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
## The pilot stands through the opening lines until about tick 1140; it walks after that.
const FROM: int = 1140
const LIMIT: int = 2700
const EVERY: int = 30
const CROP: Vector2i = Vector2i(960, 540)

var _game: PrologueGame
var _view: PrologueView
var _out: String = ""
var _log: FileAccess


func _ready() -> void:
	_out = LaunchArgs.value("--result")
	if _out.is_empty() or not LaunchArgs.has("--bot"):
		_fail("use --bot and --result=<abs dir>")
		return
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_out)
	var clip: String = LaunchArgs.value("--clip")
	if not clip.contains("play"):
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	ViewMode.select("tilt70")
	_game = ENTRY.instantiate() as PrologueGame
	add_child(_game)
	_game.result_path = ""  # the game reads --result too: the probe owns it
	if _game.world == null:
		_fail("no prologue world")
		return
	_game.world.set_process(false)
	for child: Node in _game.get_children():
		if child is PrologueView:
			_view = child as PrologueView
	if _view == null:
		_fail("no prologue view")
		return
	if clip.contains("64"):
		_view.px_per_m = 64.0
		_view.print_stage.zoom = _view.px_per_m / SimConst.PX_PER_M
	_log = FileAccess.open(_out.path_join("ticks.jsonl"), FileAccess.WRITE)
	_run()


func _run() -> void:
	while _game.stage.tick < LIMIT:
		await get_tree().process_frame
		_game.world.loop().step()
		await RenderingServer.frame_post_draw
		var tick: int = _game.stage.tick
		var keep: bool = tick >= FROM and (tick % EVERY == 0 or tick % EVERY == 1)
		_write(tick, "a" if keep else "")
		if keep:
			_save(tick, "a")
			var look: StringName = _view.print_stage.look_id
			_view.print_stage.look_id = LookProfiles.OFF
			await RenderingServer.frame_post_draw
			_write(tick, "b")
			_save(tick, "b")
			_view.print_stage.look_id = look
			await RenderingServer.frame_post_draw
	_log.close()
	get_tree().quit(0)


func _write(tick: int, pass_id: String) -> void:
	var stage: PrintStage = _view.print_stage
	var cam: Camera2D = stage.camera
	var rivet: Vector2 = _game.stage.arena.rivet.pos
	var row: Dictionary = {
		"tick": tick,
		"pass": pass_id,
		"cam": [cam.position.x, cam.position.y],
		"zoom": [cam.zoom.x, cam.zoom.y],
		"world_px": [stage.world_px.x, stage.world_px.y],
		"canvas_origin": _origin(),
		"stretch": _stretch(),
		"rivet_m": [rivet.x, rivet.y],
		"look": String(stage.look_id),
		"crop_at": _crop_at(),
	}
	@warning_ignore("return_value_discarded")
	_log.store_line(JSON.stringify(row))


## The screen position of world (0, 0) on the world canvas this frame.
func _origin() -> Array:
	var o: Vector2 = get_viewport().get_canvas_transform() * Vector2.ZERO
	return [o.x, o.y]


## The window's stretch (logical px -> render px): scale x, scale y, origin x, origin y.
func _stretch() -> Array:
	var t: Transform2D = get_viewport().get_final_transform()
	return [t.get_scale().x, t.get_scale().y, t.origin.x, t.origin.y]


func _crop_at() -> Array:
	var size: Vector2i = get_viewport().get_texture().get_size()
	var at: Vector2i = (size - CROP) / 2
	return [at.x, at.y]


func _save(tick: int, pass_id: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	var at: Vector2i = (image.get_size() - CROP) / 2
	var crop: Image = image.get_region(Rect2i(at, CROP))
	if crop.save_png(_out.path_join("t%05d_%s.png" % [tick, pass_id])) != OK:
		_fail("png save failed")


func _fail(message: String) -> void:
	Log.error("drift-probe", message)
	get_tree().quit(2)
