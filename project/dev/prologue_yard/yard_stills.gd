extends Node
## Capture the real seed-7 pilot, with the HUD hidden so every pixel of the yard is inspectable.

const KNOWN_FLAGS: PackedStringArray = ["--dressing", "--tick", "--out"]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60
const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const PILOT: GDScript = preload("res://dev/bots/prologue_bot.gd")
const SIZE: Vector2i = Vector2i(1920, 1080)

var _game: PrologueGame
var _view: PrologueView
var _tick: int
var _out: String


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	for key: String in args.values:
		if key not in KNOWN_FLAGS:
			_fail("unknown yard stills option " + key)
			return
	var raw_tick: String = args.text("--tick", "300")
	_out = args.text("--out")
	if not raw_tick.is_valid_int() or raw_tick.to_int() < 0 or not _out.is_absolute_path():
		_fail("use a nonnegative tick and an absolute output directory")
		return
	_tick = raw_tick.to_int()
	if DisplayServer.get_name() == "headless" or DirAccess.make_dir_recursive_absolute(_out) != OK:
		_fail("capture requires a window and a writable output directory")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = SIZE
	ViewMode.select("tilt70")
	var flags: PackedStringArray = ["--seed=7"]
	if args.has("--dressing"):
		@warning_ignore("return_value_discarded")
		flags.append("--yard-dressing=" + args.text("--dressing"))
	LaunchArgs.parse(flags)
	_game = ENTRY.instantiate() as PrologueGame
	add_child(_game)
	_game.world.set_process(false)
	var pilot: InputSource = PILOT.new(_game.stage, _game.encounter)
	_game.world.loop().set_input(pilot)
	_capture.call_deferred()


func _capture() -> void:
	while _game.stage.tick < _tick:
		var end_tick: int = _game.encounter.street.end_tick
		if end_tick >= 0 and _game.stage.tick >= end_tick + PrologueStreet.END_TICKS:
			_fail("tick %d is past the end of the prologue" % _tick)
			return
		_game.world.loop().step()
	var plan: PrologueYard = _game.stage.plan as PrologueYard
	for child: Node in _game.get_children():
		if child is PrologueView:
			_view = child as PrologueView
			break
	# Let the cast, pools and props update to this tick before pinning the camera.
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_view.set_process(false)
	for node: Node in _view.get_children():
		var layer: CanvasLayer = node as CanvasLayer
		if layer != null and layer.layer == RenderLayers.canvas(&"hud"):
			layer.visible = false
	var places: Dictionary[String, Vector2] = {
		"gate": plan.gate,
		"mid": plan.rivet_start,
		"harbor": Vector2(plan.street.end.x, plan.street.get_center().y)
	}
	for place: String in places:
		for ppm: int in [32, 64]:
			if not await _save(place, places[place], ppm, plan.dressing.id):
				return
	get_tree().quit()


func _save(place: String, at: Vector2, ppm: int, dressing: String) -> bool:
	_view.px_per_m = float(ppm)
	_view.print_stage.zoom = float(ppm) / SimConst.PX_PER_M
	_view.print_stage.place(at)
	_view.print_stage.camera.force_update_scroll()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var file: String = "%s_%dppm_%s_t%d.png" % [place, ppm, dressing, _tick]
	if image == null or image.get_size() != SIZE or _game.stage.tick != _tick:
		_fail("viewport or tick mismatch for " + file)
		return false
	if image.save_png(_out.path_join(file)) != OK:
		_fail("could not write " + _out.path_join(file))
		return false
	Log.info("yard-stills", "%s at %s m, %s" % [file, at, SIZE])
	return true


func _fail(message: String) -> void:
	Log.error("yard-stills", message)
	get_tree().quit(2)
