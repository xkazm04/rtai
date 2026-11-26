extends Node
## n31-16: the prologue on the pilot bot as a player sees it: the project stretch stays on
## (canvas_items, 1280x800 base in a 1920x1080 window), tilt 70, one sim tick per frame. The film
## tools turn the stretch off; this one does not. Meant for `--write-movie`. The first FROM
## ticks (the opening lines, the pilot stands) run without a frame; the take is FROM..LIMIT.
## --clip=<ppm>:<from>:<limit> (default 32:1140:2700) sets the view scale, the first and the last
## drawn tick; --result=<abs dir> gets ticks.jsonl (tick, Rivet metres, world_px, stretch).

const KNOWN_FLAGS: PackedStringArray = ["--bot", "--clip", "--result", "--seed"]
const NEEDS_WINDOW: bool = true
const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const DEFAULT_CLIP: String = "32:1140:2700"

var _game: PrologueGame
var _view: PrologueView
var _log: FileAccess
var _clip: PackedStringArray = DEFAULT_CLIP.split(":")


func _ready() -> void:
	var out: String = LaunchArgs.value("--result")
	if out.is_empty() or not LaunchArgs.has("--bot"):
		Log.error("play-film", "use --bot and --result=<abs dir>")
		get_tree().quit(2)
		return
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(out)
	ViewMode.select("tilt70")
	_game = ENTRY.instantiate() as PrologueGame
	add_child(_game)
	_game.result_path = ""
	_game.world.set_process(false)
	for child: Node in _game.get_children():
		if child is PrologueView:
			_view = child as PrologueView
	if _view == null:
		Log.error("play-film", "no prologue view")
		get_tree().quit(2)
		return
	if LaunchArgs.has("--clip"):
		_clip = LaunchArgs.value("--clip").split(":")
	var ppm: float = _clip[0].to_float()
	_view.px_per_m = ppm
	_view.print_stage.zoom = ppm / SimConst.PX_PER_M
	_log = FileAccess.open(out.path_join("ticks.jsonl"), FileAccess.WRITE)
	_run()


func _run() -> void:
	var first: int = _clip[1].to_int()
	var limit: int = _clip[2].to_int()
	await get_tree().process_frame
	while _game.stage.tick < first:
		_game.world.loop().step()
	while _game.stage.tick < limit:
		await get_tree().process_frame
		_game.world.loop().step()
		await RenderingServer.frame_post_draw
		_write()
	_log.close()
	get_tree().quit(0)


func _write() -> void:
	var stage: PrintStage = _view.print_stage
	var rivet: Vector2 = _game.stage.arena.rivet.pos
	var t: Transform2D = get_viewport().get_final_transform()
	var o: Vector2 = get_viewport().get_canvas_transform() * Vector2.ZERO
	var row: Dictionary = {
		"tick": _game.stage.tick,
		"rivet_m": [rivet.x, rivet.y],
		"world_px": [stage.world_px.x, stage.world_px.y],
		"canvas_origin": [o.x, o.y],
		"stretch": [t.get_scale().x, t.get_scale().y, t.origin.x, t.origin.y],
		"window": [get_window().size.x, get_window().size.y],
	}
	@warning_ignore("return_value_discarded")
	_log.store_line(JSON.stringify(row))
