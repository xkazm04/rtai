extends Node

const KNOWN_FLAGS: PackedStringArray = ["--dressing", "--tick", "--out", "--footprints", "--tilt"]
const NEEDS_WINDOW: bool = true
const FIXED_FPS: int = 60
const SIZE: Vector2i = Vector2i(1920, 1080)

var _game: PrologueGame
var _view: PrologueView
var _tick: int
var _out: String
@onready var _outlines: Node2D = $Guide/Footprints


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	for key: String in args.values:
		if key not in KNOWN_FLAGS or (key == "--tilt" and args.text(key) not in ["55", "70"]):
			_fail("invalid yard stills option " + key)
			return
	var raw_tick: String = args.text("--tick", "300")
	_out = args.text("--out").path_join("tilt55" if args.text("--tilt") == "55" else "")
	if not raw_tick.is_valid_int() or raw_tick.to_int() < 0 or not _out.is_absolute_path():
		_fail("use a nonnegative tick and an absolute output directory")
		return
	_outlines.visible = args.has("--footprints")
	_tick = raw_tick.to_int()
	if DisplayServer.get_name() == "headless" or DirAccess.make_dir_recursive_absolute(_out) != OK:
		_fail("capture requires a window and a writable output directory")
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = SIZE
	ViewMode.select("tilt" if args.text("--tilt") == "55" else "tilt70")
	LaunchArgs.parse(["--seed=7", "--yard-dressing=" + args.text("--dressing")])
	_game = preload("res://boot/prologue/prologue.tscn").instantiate()
	add_child(_game)
	_game.world.set_process(false)
	const Pilot = preload("res://dev/bots/prologue_bot.gd")
	_game.world.loop().set_input(Pilot.new(_game.stage, _game.encounter))
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
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	_view.set_process(false)
	YardCamera.hide_hud(_view)
	_outlines.transform = _view.stage_view.global_transform
	if _outlines.visible:
		if await _save(plan.rivet_start, 64, "footprints_mid_64ppm.png"):
			get_tree().quit()
		return
	for place: String in ["gate", "mid", "harbor", "west"]:
		for ppm: int in [32, 64]:
			var file: String = "%s_%dppm_%s_t%d.png" % [place, ppm, plan.dressing.id, _tick]
			if not await _save(YardCamera.center(plan, place), ppm, file):
				return
	get_tree().quit()


func _draw_footprints() -> void:
	for prop: ArenaStation.Prop in (_game.stage.plan as PrologueYard).stations.stations[0].props:
		var rect: Rect2 = PrologueYardPaint.pixels(Rect2(prop.at - prop.size * 0.5, prop.size))
		_outlines.draw_rect(rect, Color("241627"), false, 2.8)
		_outlines.draw_rect(rect, Color("f7c8ff"), false, 1.4)


func _save(at: Vector2, ppm: int, file: String) -> bool:
	YardCamera.place(_view, at, ppm)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var valid: bool = image != null and image.get_size() == SIZE and _game.stage.tick == _tick
	if not valid or image.save_png(_out.path_join(file)) != OK:
		_fail("capture failed at tick %d for %s" % [_game.stage.tick, _out.path_join(file)])
		return false
	Log.info("yard-stills", "%s at %s m, tilt %.0f" % [file, at, ViewMode.shared().pitch_deg])
	return true


func _fail(message: String) -> void:
	Log.error("yard-stills", message)
	get_tree().quit(2)
