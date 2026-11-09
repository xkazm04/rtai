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
const BACKPEDAL_DOT: float = -0.25
## Frames without ground walked before the figure stands.
const STILL_FRAMES: int = 3
const OCT_HOLD_RAD: float = deg_to_rad(4.0)
## The act grid (`<name>_act.png`): 4 columns, the phases: wind-up (unused: the sim counts a strike
## only as it lands), cut, follow-through, hit; ticks each phase shows for.
const ACT_COLS: int = 4
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
var _act_tex: Texture2D = null
var _seq: int = 0
var _fed: bool = false
var _act_from: int = -1
var _hurt: int = -1
var _tick: int = 0


func _init(p_name: String, p_height_m: float, p_cycle_cell: float, p_fig_px: float) -> void:
	card_name = p_name
	height_m = p_height_m
	cycle_cell = p_cycle_cell
	fig_px = p_fig_px


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
	_show(act >= 0)
	_spr.frame = (
		RigHeadCard.OCT_FRAME[o] * (ACT_COLS if act >= 0 else COLS)
		+ maxi(act, walk if act < 0 else 0)
	)
	_spr.flip_h = RigHeadCard.OCT_FLIP[o] == 1
	_spr.global_rotation = 0.0
	_spr.global_scale = Vector2(s, s / vm.ground_k())
	return true


static func path_of(art: String, name: String) -> String:
	return ART_DIR.path_join(art).path_join(name + "_walk8.png")


static func act_path_of(art: String, name: String) -> String:
	return ART_DIR.path_join(art).path_join(name + "_act.png")


## Each frame (GhostActs): `seq` a counter that rises on a strike, `hurt` the tick of the last hit.
func feed(seq: int, hurt: int, tick: int) -> void:
	if _fed and seq > _seq:
		_act_from = tick
	_fed = true
	_seq = seq
	_hurt = hurt
	_tick = tick


## The act column to show now, -1 for the walk. A strike wins over a hit.
func act_col() -> int:
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
	if still or px / SimClock.TICK_DT < WALK_FROM_MPS * SimConst.PX_PER_M:
		_still += 1  # a frame with no sim step (a hit-stop, a fast display) keeps the stride
		_col = STAND_COL if _still > STILL_FRAMES else _col
		return _col
	_still = 0
	var cycle: float = maxf(cycle_cell * s, px / SimClock.TICK_DT / MAX_CYCLES_S)
	var back: bool = moved.normalized().dot(Vector2.from_angle(_facing(host))) < BACKPEDAL_DOT
	_phase = fposmod(_phase + px / cycle * (-1.0 if back else 1.0), 1.0)
	_col = mini(int(_phase * COLS), COLS - 1)
	return _col


func _show(act: bool) -> void:
	var tex: Texture2D = _act_tex if act else _walk_tex
	if _spr.texture == tex:
		return
	var cols: int = ACT_COLS if act else COLS
	_spr.frame = 0  # the two grids differ in size: never out of range mid-swap
	_spr.texture = tex
	_spr.hframes = cols
	_spr.vframes = ROWS
	var cell: Vector2 = tex.get_size() / Vector2(cols, ROWS)
	_spr.offset = Vector2(-cell.x * 0.5, PAD_PX - cell.y)


func _facing(host: Node2D) -> float:
	return host.global_rotation if is_nan(_look) else _look


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
		_spr.centered = false
		_show(false)
		_spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		host.add_child(_spr)
	for p: Sprite2D in parts:
		p.visible = _spr == null
