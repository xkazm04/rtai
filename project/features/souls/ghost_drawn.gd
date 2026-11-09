class_name GhostDrawn
extends RefCounted
## n11 hero: a ghost form as one drawn figure under a tilt, in Rivet's strip format: an 8-frame walk
## grid (5 facings, the left three mirrored; `<name>_walk8.png`, tools/art/ghost_pack.py), stepped
## by the ground walked so a planted foot stays put, feet on the rig's point, the rig's limbs and
## card hidden. Without the art it builds nothing and the form keeps its card. Render only.

const ART_DIR: String = "res://features/souls/art/view/"
const COLS: int = 8
const ROWS: int = 5
const PAD_PX: float = 2.0
## The standing cell (a passing frame, most upright) and the walk's speed floor (m/s).
const STAND_COL: int = 2
const WALK_FROM_MPS: float = 0.4
## The cadence's cap (cycles a second): past it the feet slide rather than churn.
const MAX_CYCLES_S: float = 3.0
## The run grid (`<name>_run8.png`, optional) takes over above this speed, with its own cap.
const RUN_FROM_MPS: float = 5.0
const MAX_RUN_CYCLES_S: float = 3.5
const BACKPEDAL_DOT: float = -0.25
## Frames without ground walked before the figure stands.
const STILL_FRAMES: int = 3
const OCT_HOLD_RAD: float = deg_to_rad(4.0)
## The act grid (`<name>_act.png`): 4 columns, the phases: wind-up (only a form whose sim has one,
## Tonnage's slam), cut, follow-through, hit; ticks each phase shows for.
const ACT_COLS: int = 4
const WINDUP_COL: int = 0
const CUT_COL: int = 1
const FOLLOW_COL: int = 2
const HIT_COL: int = 3
const CUT_TICKS: int = 5
const FOLLOW_TICKS: int = 10
const HIT_TICKS: int = 10

var card_name: String = ""
var height_m: float = 1.75
## One drawn stride cycle's ground in cell px (the stance foot's travel over a cycle, measured).
var cycle_cell: float = 150.0
## The run grid's stride cycle in cell px (0 = this ghost has no run grid).
var run_cell: float = 0.0
## The figure's median height in the grid, cell px (ghost_pack prints it).
var fig_px: float = 180.0
## True while something else carries the form (Dent braced on a car roof): stands, feet still.
var still: bool = false
var _spr: Sprite2D = null
var _art: String = "?"
var _phase: float = 0.0
var _last: Vector2 = Vector2.INF
var _col: int = STAND_COL
var _still: int = 0
var _oct: int = -1
var _look: float = NAN
var _walk_tex: Texture2D = null
var _run_tex: Texture2D = null
var _running: bool = false
var _windup: bool = false
var _act_tex: Texture2D = null
var _seq: int = 0
var _fed: bool = false
var _act_from: int = -1
var _hurt: int = -1
var _tick: int = 0


func _init(
	p_name: String, p_height_m: float, p_cycle_cell: float, p_fig_px: float, p_run_cell: float = 0.0
) -> void:
	card_name = p_name
	height_m = p_height_m
	cycle_cell = p_cycle_cell
	fig_px = p_fig_px
	run_cell = p_run_cell


## Each pose: builds the sprite on a view change, faces and steps it. Returns true while it draws
## (the caller then skips its card); `parts` hide with it. `size_k`: the rig's unfold.
func step(
	host: Node2D, parts: Array[Sprite2D], px_per_m: float, size_k: float, look: float = NAN
) -> bool:
	var vm: ViewMode = ViewMode.shared()
	if vm.art != _art:
		_rebuild(host, parts, vm)
	if _spr == null:
		return false
	var s: float = height_m * size_k * px_per_m * absf(host.global_scale.x) / fig_px
	_look = host.global_rotation if is_nan(look) else look
	var o: int = octant(_look)
	var walk: int = _column(host, s)
	var act: int = act_col() if _act_tex != null else -1
	if act >= 0:
		_show(_act_tex, ACT_COLS)
	else:
		_show(_run_tex if _running and _run_tex != null else _walk_tex, COLS)
	var cols: int = ACT_COLS if act >= 0 else COLS
	_spr.frame = RigHeadCard.OCT_FRAME[o] * cols + (act if act >= 0 else walk)
	_spr.flip_h = RigHeadCard.OCT_FLIP[o] == 1
	_spr.global_rotation = 0.0
	_spr.global_scale = Vector2(s, s / vm.ground_k())
	return true


static func path_of(art: String, name: String) -> String:
	return ART_DIR.path_join(art).path_join(name + "_walk8.png")


static func act_path_of(art: String, name: String) -> String:
	return ART_DIR.path_join(art).path_join(name + "_act.png")


static func run_path_of(art: String, name: String) -> String:
	return ART_DIR.path_join(art).path_join(name + "_run8.png")


## Each frame (GhostActs): `seq` a counter that rises on a strike, `hurt` the tick of the last hit,
## `windup` true while the sim holds a telegraphed strike.
func feed(seq: int, hurt: int, tick: int, windup: bool = false) -> void:
	if _fed and seq > _seq:
		_act_from = tick
	_fed = true
	_seq = seq
	_hurt = hurt
	_tick = tick
	_windup = windup


## The act column to show now, -1 for the walk. A strike wins over a hit, a wind-up over both.
func act_col() -> int:
	if _windup:
		return WINDUP_COL
	var since: int = _tick - _act_from
	if _act_from >= 0 and since < CUT_TICKS + FOLLOW_TICKS:
		return CUT_COL if since < CUT_TICKS else FOLLOW_COL
	return HIT_COL if _hurt >= 0 and _tick - _hurt < HIT_TICKS else -1


## The drawn octant of `look`, held OCT_HOLD_RAD past the boundary (as Rivet's RivetStride.oct_of).
func octant(look: float) -> int:
	if _oct >= 0 and absf(angle_difference(look, _oct * PI * 0.25)) <= PI / 8.0 + OCT_HOLD_RAD:
		return _oct
	_oct = posmod(roundi(look / (PI * 0.25)), 8)
	return _oct


## The grid column by the ground walked; the standing cell below the walk's speed.
func _column(host: Node2D, s: float) -> int:
	var at: Vector2 = host.global_position
	var moved: Vector2 = Vector2.ZERO if _last == Vector2.INF else at - _last
	_last = at
	var px: float = moved.length()
	var speed: float = px / SimClock.TICK_DT
	if still or speed < WALK_FROM_MPS * SimConst.PX_PER_M:
		_still += 1  # a frame with no sim step (a hit-stop, a fast display) keeps the stride
		if _still > STILL_FRAMES:
			_col = STAND_COL
			_running = false
		return _col
	_still = 0
	_running = run_cell > 0.0 and speed > RUN_FROM_MPS * SimConst.PX_PER_M
	var cell: float = run_cell if _running else cycle_cell
	var cap: float = MAX_RUN_CYCLES_S if _running else MAX_CYCLES_S
	var cycle: float = maxf(cell * s, speed / cap)
	var look: float = host.global_rotation if is_nan(_look) else _look
	var back: bool = moved.normalized().dot(Vector2.from_angle(look)) < BACKPEDAL_DOT
	_phase = fposmod(_phase + px / cycle * (-1.0 if back else 1.0), 1.0)
	_col = mini(int(_phase * COLS), COLS - 1)
	return _col


func _show(tex: Texture2D, cols: int) -> void:
	if _spr.texture == tex:
		return
	_spr.frame = 0  # the grids differ in size: never out of range mid-swap
	_spr.texture = tex
	_spr.hframes = cols
	_spr.vframes = ROWS
	var cell: Vector2 = tex.get_size() / Vector2(cols, ROWS)
	_spr.offset = Vector2(-cell.x * 0.5, PAD_PX - cell.y)


func _rebuild(host: Node2D, parts: Array[Sprite2D], vm: ViewMode) -> void:
	if _spr != null:
		_spr.queue_free()
		_spr = null
	_art = vm.art
	var path: String = path_of(_art, card_name)
	if vm.cards and _art != "" and ResourceLoader.exists(path):
		_spr = Sprite2D.new()
		_spr.name = &"ghost_drawn"
		_walk_tex = load(path) as Texture2D
		var act: String = act_path_of(_art, card_name)
		_act_tex = load(act) as Texture2D if ResourceLoader.exists(act) else null
		var run: String = run_path_of(_art, card_name)
		_run_tex = load(run) as Texture2D if ResourceLoader.exists(run) else null
		_spr.centered = false
		_show(_walk_tex, COLS)
		_spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		host.add_child(_spr)
	for p: Sprite2D in parts:
		p.visible = _spr == null
