class_name GhostDrawn
extends RefCounted
## Draws the ghost's walk, hover and combat cells at the rig's point.

const ART_DIR: String = "res://features/souls/art/view/"
const COLS: int = 8
const ROWS: int = 5
const PAD_PX: float = 2.0
const STAND_COL: int = 2  # the standing cell (a passing frame, most upright)
const SPEC_CRUISE_MPS: float = 0.5
const WALK_FROM_MPS: float = 0.4  # the walk's speed floor (m/s)
const MAX_CYCLES_S: float = 3.0  # the cadence's cap (cycles/s): past it the feet slide
const RUN_FROM_MPS: float = 5.0  # the run grid (optional) takes over above this, with its own cap
const MAX_RUN_CYCLES_S: float = 3.5
const BACKPEDAL_DOT: float = -0.25
const STRIDE_K: Dictionary[String, float] = {"dent/p55": 0.8, "tonnage/p55": 0.95}
const STILL_FRAMES: int = 3  # frames without ground walked before the figure stands
const OCT_HOLD_RAD: float = deg_to_rad(4.0)
const ACT_COLS: int = 4
const WINDUP_COL: int = 0
const CUT_COL: int = 1
const FOLLOW_COL: int = 2
const HIT_COL: int = 3
const JAB_SHIFT: int = 4  # Dent's optional jab cells occupy columns 4-6 on each side.
const JAB_COLS: Dictionary[String, int] = {"dent/p70": 7, "dent/p55": 7}
const JAB_LEFT_COLS: Dictionary[String, int] = {"dent/p70": 7, "dent/p55": 7}
const CUT_TICKS: int = 5
const FOLLOW_TICKS: int = 10
const HIT_TICKS: int = 10
const HIT_FROM_BEHIND: bool = true
const REAR_DOT: float = 0.5  # within 60 degrees of the facing, including the adjacent octants

var card_name: String = ""
var height_m: float = 1.75
var cycle_cell: float = 150.0  # measured stance foot travel per cycle (cell px)
var run_cell: float = 0.0  # the run grid's stride cycle in cell px (0 = no run grid)
var fig_px: float = 180.0  # the figure's median height in the grid, cell px (ghost_pack prints it)
var flight: GhostFlight
var hover: bool = false
var pose: int = -1
var instant_windup: int = 0
var still: bool = false  # something else carries the form (Dent on a car roof): stands still
var blow: Vector2 = Vector2.ZERO  # the last hit's line (GhostActs, Fighter.hurt_dir; ZERO = none)
var jab: bool = false  # the strike or wind-up shown is Dent's arm jab (GhostActs)
var _spr: Sprite2D = null
var _art: String = "?"
var _built_hover: bool = false
var _steps: PackedFloat32Array = PackedFloat32Array()  # measured stride per frame; empty = even
var _run_steps: PackedFloat32Array = PackedFloat32Array()  # GhostStride.run_table_of
var _phase: float = 0.0
var _last: Vector2 = Vector2.INF
var _col: int = STAND_COL
var _still: int = 0
var _oct: int = -1
var _look: float = NAN
var _walk: GhostSheet = null
var _run: GhostSheet = null
var _running: bool = false
var _windup: bool = false
var _act: GhostSheet = null
var _seq: int = 0
var _fed: bool = false
var _act_from: int = -1
var _hurt: int = -1
var _tick: int = 0
var _lunge: GhostLunge = GhostLunge.new()  # the strike's lean and the wind-up's (n15 combat feel)


func _init(
	p_name: String, p_height_m: float, p_cycle_cell: float, p_fig_px: float, p_run_cell: float = 0.0
) -> void:
	card_name = p_name
	height_m = p_height_m
	cycle_cell = p_cycle_cell
	fig_px = p_fig_px
	run_cell = p_run_cell
	if card_name == "ohm" and not GhostLook.spectral(&"ohm"):
		instant_windup = int(GhostAttacks.shipped().num(&"ohm", &"bolt_windup_ticks"))


func sprite() -> Sprite2D:
	return _spr


func step(
	host: Node2D, parts: Array[Sprite2D], px_per_m: float, size_k: float, look: float = NAN
) -> bool:
	var vm: ViewMode = ViewMode.shared()
	if vm.art != _art or _built_hover != hover:
		_built_hover = hover
		_rebuild(host, parts, vm)
	if _spr == null:
		return false
	var fit: float = absf(host.scale.x if flight != null else host.global_scale.x)
	var s: float = height_m * size_k * px_per_m * fit / fig_px
	var yaw: float = flight.body_rotation() if flight != null else 0.0
	_look = host.global_rotation if is_nan(look) else look + yaw
	var o: int = octant(_look)
	var walk: int = _column(host, s, RigHeadCard.OCT_FRAME[o])
	var act: int = jab_col(act_col(), jab, _act.cols) if _act != null else -1
	var sheet: GhostSheet = _act if act >= 0 else (_run if _running and _run != null else _walk)
	_show_cell(sheet, o, act if act >= 0 else walk)
	var hurt: int = _tick - _hurt if act == HIT_COL else -1
	var since: int = _tick - _act_from if _act_from >= 0 else -1
	var tilt: float = GhostRecoil.tilt(hurt, _look, GhostRecoil.lean_of(card_name), blow)
	_spr.global_rotation = tilt + _lunge.lean(_tick, since, _windup, _look, card_name)
	var reach: Vector2 = GhostLunge.reach(since, _look, card_name) * SimConst.PX_PER_M * size_k
	_spr.global_position = host.global_position + reach
	var bank_scale: Vector2 = flight.body_scale() if flight != null else Vector2.ONE
	_spr.global_scale = Vector2(s, s / vm.ground_k()) * bank_scale
	GhostHand.note(card_name, _art, _spr, o, act >= 0 and act != HIT_COL)
	return true


func _show_cell(sheet: GhostSheet, oct: int, col: int, rear_hits: bool = HIT_FROM_BEHIND) -> void:
	var rear: bool = rear_hits and blow.normalized().dot(Vector2.from_angle(_look)) > REAR_DOT
	sheet.show(_spr, oct, col, -1.0 if hover or _still > STILL_FRAMES else _phase, rear)


static func path_of(art: String, name: String, sheet: String = "walk8") -> String:
	return ART_DIR.path_join(art).path_join("%s_%s.png" % [name, sheet])


func feed(seq: int, hurt: int, tick: int, windup: bool = false, release_tick: int = -1) -> void:
	if release_tick >= 0:
		_act_from = release_tick
		instant_windup = 0  # this cast already showed its wind-up before release
	elif _fed and seq > _seq:
		_act_from = tick
	_fed = true
	_seq = seq
	_hurt = hurt
	_tick = tick
	_windup = windup


func act_col() -> int:
	if _windup:
		return WINDUP_COL
	var since: int = _tick - _act_from
	if _act_from >= 0 and since < CUT_TICKS + FOLLOW_TICKS:
		if since < instant_windup:
			return WINDUP_COL
		return CUT_COL if since < CUT_TICKS else FOLLOW_COL
	return HIT_COL if _hurt >= 0 and _tick - _hurt < HIT_TICKS else -1


static func jab_col(act: int, p_jab: bool, cols: int) -> int:
	var shift: bool = p_jab and act >= 0 and act != HIT_COL and cols > JAB_SHIFT
	return act + JAB_SHIFT if shift else act


func octant(look: float) -> int:
	if _oct < 0 or absf(angle_difference(look, _oct * PI * 0.25)) > PI / 8.0 + OCT_HOLD_RAD:
		_oct = posmod(roundi(look / (PI * 0.25)), 8)
	return _oct


func _column(host: Node2D, s: float, row: int) -> int:
	var moved: Vector2 = Vector2.ZERO if _last == Vector2.INF else host.global_position - _last
	_last = host.global_position
	var px: float = moved.length()
	var speed: float = px / SimClock.TICK_DT
	if hover or still or speed < WALK_FROM_MPS * SimConst.PX_PER_M:
		_still += 1  # a frame with no sim step (a hit-stop, a fast display) keeps the stride
		if hover or _still > STILL_FRAMES:
			_col = roundi(STAND_COL * GhostStride.cols_of(_steps) / float(COLS))
			_running = false
		if hover and _walk != null and _walk.poses:
			var cruise: bool = flight != null and flight.hover.speed_mps >= SPEC_CRUISE_MPS
			_col = clampi(pose if pose >= 0 else int(cruise), 0, _walk.cols - 1)
		return _col
	_still = 0
	var fast: bool = speed > RUN_FROM_MPS * SimConst.PX_PER_M and _run != null
	_running = fast and run_cell > 0.0 and GhostStride.runs(card_name, _art, row)
	var k: float = STRIDE_K.get(card_name + "/" + _art, 1.0)
	var cell: float = (run_cell if _running else cycle_cell) * k
	var cap: float = MAX_RUN_CYCLES_S if _running else MAX_CYCLES_S
	var cycle: float = maxf(cell * s, speed / cap)
	var look: float = host.global_rotation if is_nan(_look) else _look
	var back: bool = moved.normalized().dot(Vector2.from_angle(look)) < BACKPEDAL_DOT
	_phase = fposmod(_phase + px / cycle * (-1.0 if back else 1.0), 1.0)
	_col = GhostStride.col_of(_phase, _run_steps if _running else _steps)
	return _col


func _rebuild(host: Node2D, parts: Array[Sprite2D], vm: ViewMode) -> void:
	_walk = null
	_run = null
	_art = vm.art
	_steps = GhostStride.table_of(card_name, _art)
	_run_steps = GhostStride.run_table_of(card_name, _art)
	if vm.cards and _art != "" and (hover or ResourceLoader.exists(path_of(_art, card_name))):
		_walk = GhostSheet.walk_of(path_of(_art, card_name), _steps, hover)
		if _walk == null and ResourceLoader.exists(path_of(_art, card_name)):
			Log.warn("ghost_drawn", "unreadable %s walk, showing the rig" % card_name)
		_act = GhostSheet.act_of(path_of(_art, card_name, "act"), card_name + "/" + _art, hover)
		var rc: int = GhostStride.cols_of(_run_steps)
		_run = null if hover else GhostSheet.of(path_of(_art, card_name, "run%d" % rc), rc)
	_spr = GhostSheet.replace_sprite(host, _spr, _walk, parts)
