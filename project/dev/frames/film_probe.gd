class_name FilmProbe
extends Node
## n11 tools, dev only (tools/film drives it; the arena's --film-dir=<abs dir> turns it on):
## per-tick numbers and tick-exact lossless stills from the live draw, so a before/after compares
## one sim tick and says what it measured. Reads the game, never writes the sim.
##   --film-dir=<dir>     writes probe.json there (and the stills)
##   --film-stills=<t,t>  saves <dir>/t<tick>.png after that tick's draw
##   --film-ticks=<a-b>   only these ticks go in probe.json (default: all)
##   --cam-lock=<x,y>     holds the camera on a world point (m), or "spawn": Rivet's first tick
## Rows: tick, frame (the movie frame), cam (camera world px), then one row per fighter with
## pos (m), screen (px), on_screen, draw (px, the opaque size of the drawn card), feet_y (px, the
## drawn card's lowest opaque row on screen, -1 = no card), facing_off (deg, drawn against sim).

const SCHEMA: String = "gtai.film-probe/1"
const PRIORITY: int = 60
const NO_DRAW: float = -1.0

var game: ArenaGame = null
var out_dir: String = ""
var stills: Array[int] = []
var window: Vector2i = Vector2i(0, 2147483647)
var lock: Vector2 = Vector2.INF
var lock_spawn: bool = false
var _rows: Array[Dictionary] = []
var _saved: Array[int] = []
var _last_tick: int = -1
var _used: Dictionary[String, Rect2i] = {}
var _written: bool = false
var _saving: bool = false
var _view: Vector2 = Vector2.ZERO


static func attach(parent: ArenaGame, args: ArenaArgs) -> void:
	if not args.has("--film-dir") and not args.has("--cam-lock"):
		return
	var p: FilmProbe = FilmProbe.new()
	p.game = parent
	p.out_dir = args.text("--film-dir")
	for t: String in args.text("--film-stills").split(",", false):
		p.stills.append(t.to_int())
	var span: String = args.text("--film-ticks")
	if span.contains("-"):
		p.window = Vector2i(span.get_slice("-", 0).to_int(), span.get_slice("-", 1).to_int())
	var cam: String = args.text("--cam-lock")
	if cam == "spawn":
		p.lock_spawn = true
	elif cam.contains(","):
		p.lock = Vector2(cam.get_slice(",", 0).to_float(), cam.get_slice(",", 1).to_float())
	parent.add_child(p)


func _ready() -> void:
	process_priority = PRIORITY
	if out_dir != "":
		@warning_ignore("return_value_discarded")
		DirAccess.make_dir_recursive_absolute(out_dir)


func _process(_delta: float) -> void:
	if game == null or game.session == null:
		return
	_hold_camera()
	_view = get_viewport().get_visible_rect().size
	var tick: int = game.session.tick()
	if tick != _last_tick and out_dir != "":
		_last_tick = tick
		if tick >= window.x and tick <= window.y:
			_rows.append(_row(tick))
		if stills.has(tick) and not _saved.has(tick) and not _saving:
			_saving = true
			_grab.call_deferred(tick)


## Locks the view on a world point. The arena camera takes `focus`; on the city the streaming focus
## stays on Rivet and the camera leans by the difference (CollectCallView.city_lean_m).
func _hold_camera() -> void:
	var rivet: Fighter = game.session.stage.arena.rivet
	if lock_spawn and lock == Vector2.INF:
		lock = rivet.pos
	if lock == Vector2.INF:
		return
	if game.view.city != null:
		game.view.city_lean_m = lock - rivet.pos
	else:
		game.view.focus = lock


func _grab(tick: int) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var err: Error = image.save_png(out_dir.path_join("t%d.png" % tick))
	Log.info("film", "still t%d (%s)" % [tick, error_string(err)])
	if err == OK:
		_saved.append(tick)
	_saving = false


func _row(tick: int) -> Dictionary:
	var arena: CombatArena = game.session.stage.arena
	var fighters: Array[Dictionary] = [_fighter(arena.rivet, "rivet")]
	for h: Fighter in arena.hostiles:
		fighters.append(_fighter(h, "hostile"))
	var cam: Vector2 = get_viewport().get_canvas_transform().origin
	return {
		"tick": tick,
		"frame": Engine.get_process_frames(),
		"cam": [cam.x, cam.y],
		"fighters": fighters
	}


func _fighter(f: Fighter, role: String) -> Dictionary:
	var sprite: Sprite2D = _drawn(f)
	var size: Vector2 = Vector2(NO_DRAW, NO_DRAW)
	var feet: float = NO_DRAW
	var screen: Vector2 = _screen_of(f, sprite)
	var used: Rect2i = FilmCard.used_rect(sprite, _used)
	if used.size != Vector2i.ZERO:
		size = Vector2(used.size) * sprite.global_scale.abs()
		feet = FilmCard.feet_y(sprite, used)
	var rect: Rect2 = get_viewport().get_visible_rect()
	return {
		"id": f.id,
		"role": role,
		"alive": f.alive(),
		"hp": f.hp,
		"pos": [f.pos.x, f.pos.y],
		"screen": [screen.x, screen.y],
		"on_screen": rect.has_point(screen),
		"draw": [size.x, size.y],
		"feet_y": feet,
		"facing_off": _facing_off(f),
	}


func _rig(f: Fighter) -> CutRig:
	return null if game.cast == null else game.cast.rigs.rig_for(f.id)


## The card drawing `f` now: the lying sprite kept for the dead, else the upright head card.
func _drawn(f: Fighter) -> Sprite2D:
	var rig: CutRig = _rig(f)
	if rig != null and rig.head_card != null:
		var lying: Sprite2D = rig.head_card.get_node_or_null(StreetDeadPlan.NODE) as Sprite2D
		if lying != null:
			return lying
		if rig.head_card.visible:
			return rig.head_card
	return _kept(f.id)


## The lying sprite StreetDeadRest kept once the corpse's rig is back in the pool (its last part).
func _kept(id: int) -> Sprite2D:
	if game.cast == null or not game.cast.rigs.rest._kept.has(id):
		return null
	var parts: Array = game.cast.rigs.rest._kept[id]
	var last: Variant = parts.back() if not parts.is_empty() else null
	return last if last is Sprite2D else null


## On-screen px: from the drawn card when there is one, else the sim point through the camera.
func _screen_of(f: Fighter, sprite: Sprite2D) -> Vector2:
	if sprite != null:
		return sprite.get_global_transform_with_canvas().origin
	return get_viewport().get_canvas_transform() * Ink.px(f.pos)


## Drawn facing against the sim's aim (deg, 0 = he looks where he aims; 999 = no rig).
func _facing_off(f: Fighter) -> float:
	var rig: CutRig = _rig(f)
	if rig == null or f.facing == Vector2.ZERO:
		return 999.0
	return rad_to_deg(absf(angle_difference(rig.facing, f.facing.angle())))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_write()


func _write() -> void:
	if _written or out_dir == "":
		return
	_written = true
	var out: Dictionary = {
		"schema": SCHEMA, "stills": _saved, "rows": _rows, "view": [_view.x, _view.y]
	}
	var f: FileAccess = FileAccess.open(out_dir.path_join("probe.json"), FileAccess.WRITE)
	if f == null:
		Log.error("film", "cannot write probe.json in %s" % out_dir)
		return
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(out))
	f.close()
