extends Node
## Twelve native-scale tracking shots per frame. Columns increase in speed, rows are bare / pistol.
## Save every fixed tick after the mover reaches the target. film.json maps cells to source poses.

const RUN_TICKS: int = 300
const NEEDS_WINDOW: bool = true
const KNOWN_FLAGS: PackedStringArray = ["--ppm", "--view", "--out", "--matched"]
const SPEEDS: Array[float] = [1.2, 1.8, 2.1, 2.4, 2.6, 3.2]
const FIRST_TICK: int = 40
const END_TICK: int = 280

var _tiles: Array[WalkSlideTile] = []
var _out: String
var _ppm: int
var _view: String
var _matched: bool


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	_ppm = int(args.text("--ppm", "32"))
	_view = args.text("--view", "tilt70")
	_out = args.text("--out")
	_matched = args.has("--matched")
	for flag: String in args.values:
		if flag not in KNOWN_FLAGS:
			Log.warn("walk-slide", "unknown argument " + flag)
			get_tree().quit(2)
			return
	if _ppm not in [32, 64] or _view not in ["tilt", "tilt70"] or _out.is_empty():
		get_tree().quit(2)
		return
	if DirAccess.make_dir_recursive_absolute(_out) != OK:
		get_tree().quit(1)
		return
	ViewMode.select(_view)
	var win: Window = get_window()
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	win.size = WalkSlideTile.SIZE * Vector2i(SPEEDS.size(), 2)
	RenderingServer.set_default_clear_color(Color("#82bfc9"))
	for row: int in 2:
		for column: int in SPEEDS.size():
			var camera: CanvasLayer = CanvasLayer.new()
			add_child(camera)
			var tile: WalkSlideTile = WalkSlideTile.new()
			camera.add_child(tile)
			var at: Vector2i = Vector2i(column, row) * WalkSlideTile.SIZE
			tile.setup(camera, at, SPEEDS[column], row == 1, _ppm)
			_tiles.append(tile)
	get_tree().quit(await _film())


func _film() -> int:
	for tick: int in END_TICK:
		await get_tree().process_frame
		for tile: WalkSlideTile in _tiles:
			if not tile.advance(_matched and tick >= FIRST_TICK):
				Log.warn("walk-slide", "missing profile measurement at tick %d" % tick)
				return 1
		if tick < FIRST_TICK:
			continue
		for tile: WalkSlideTile in _tiles:
			if not tile.record_column():
				Log.warn("walk-slide", "wrong speed, row or strip at tick %d" % tick)
				return 1
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		if image.get_size() != WalkSlideTile.SIZE * Vector2i(SPEEDS.size(), 2):
			Log.warn("walk-slide", "unexpected viewport size %s" % image.get_size())
			return 1
		if image.save_png(_out.path_join("t%03d.png" % tick)) != OK:
			return 1
	var lanes: Array[Dictionary] = []
	for tile: WalkSlideTile in _tiles:
		lanes.append(tile.describe())
	var info: Dictionary = {
		"schema": "gtai.stride-film/1",
		"ppm": _ppm,
		"view": _view,
		"first_tick": FIRST_TICK,
		"lanes": lanes,
		"matched": _matched,
	}
	var output: FileAccess = FileAccess.open(_out.path_join("film.json"), FileAccess.WRITE)
	if output == null:
		return 1
	return OK if output.store_line(JSON.stringify(info)) else FAILED
