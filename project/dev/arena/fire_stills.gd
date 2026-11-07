class_name FireStills
extends Node
## Lane d9 rivet (dev): `--fire-stills=<path prefix>` saves Rivet's drawn fire cell from the game's
## own state, not from pixels: each frame his card shows an equipped FIRE_SIDE / FIRE_CAM cell
## (RivetFrames.place), a CROP_PX crop of the screen round his figure is written as
## `<prefix>_<n>_t<tick>.png`, at most STILLS of them GAP_TICKS apart, then the run quits. A run
## whose weapon never fires a drawn cell quits at `--fire-stills-max=<ticks>` (default 1500) with a
## line saying so (no still is faked).

const STILLS: int = 3
const GAP_TICKS: int = 20
const CROP_PX: int = 320
const LIFT_PX: float = 40.0

var _cast: ArenaRigs = null
var _session: ArenaSession = null
var _prefix: String = ""
var _max_tick: int = 1500
var _saved: int = 0
var _last: int = -GAP_TICKS
var _busy: bool = false


func _init(cast: ArenaRigs, session: ArenaSession, prefix: String, max_tick: int) -> void:
	_cast = cast
	_session = session
	_prefix = prefix
	_max_tick = max_tick


func _process(_delta: float) -> void:
	if _busy or _cast == null:
		return
	var tick: int = _session.tick()
	if tick >= _max_tick:
		Log.info("arena", "fire stills: %d saved by tick %d (%s)" % [_saved, tick, _prefix])
		get_tree().quit(0 if _saved > 0 else 1)
		return
	var rig: CutRig = _cast.rigs.rig_for(_session.stage.arena.rivet.id)
	if rig == null or not RivetFrames.owns_weapon(rig) or tick - _last < GAP_TICKS:
		return
	var cell: int = rig.head_card.frame
	if cell != RivetFrames.Eq.FIRE_SIDE and cell != RivetFrames.Eq.FIRE_CAM:
		return
	_busy = true
	_save.call_deferred(rig, tick, cell)


func _save(rig: CutRig, tick: int, cell: int) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	var at: Vector2 = rig.get_global_transform_with_canvas().origin - Vector2(0.0, LIFT_PX)
	var r: Rect2i = Rect2i(Vector2i(at) - Vector2i.ONE * (CROP_PX >> 1), Vector2i.ONE * CROP_PX)
	r = r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	var path: String = "%s_%d_t%d_c%d.png" % [_prefix, _saved, tick, cell]
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var err: Error = img.get_region(r).save_png(path)
	Log.info("arena", "fire still %s (%s)" % [path, error_string(err)])
	_saved += 1
	_last = tick
	_busy = false
	if _saved >= STILLS:
		get_tree().quit(0)
