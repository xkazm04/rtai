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

var card_name: String = ""
var height_m: float = 1.75
## One drawn stride cycle's ground in cell px (the stance foot's travel over a cycle, measured).
var cycle_cell: float = 150.0
## The figure's median height in the grid, cell px (ghost_pack prints it).
var fig_px: float = 180.0
var _spr: Sprite2D = null
var _art: String = "?"
var _phase: float = 0.0
var _last: Vector2 = Vector2.INF
var _col: int = STAND_COL
var _still: int = 0
var _oct: int = -1


func _init(p_name: String, p_height_m: float, p_cycle_cell: float, p_fig_px: float) -> void:
	card_name = p_name
	height_m = p_height_m
	cycle_cell = p_cycle_cell
	fig_px = p_fig_px


## Each pose: builds the sprite on a view change, faces and steps it. Returns true while it draws
## (the caller then skips its card); `parts` hide with it. `size_k`: the rig's unfold.
func step(host: Node2D, parts: Array[Sprite2D], px_per_m: float, size_k: float) -> bool:
	var vm: ViewMode = ViewMode.shared()
	if vm.art != _art:
		_rebuild(host, parts, vm)
	if _spr == null:
		return false
	var s: float = height_m * size_k * px_per_m * absf(host.global_scale.x) / fig_px
	var o: int = octant(host.global_rotation)
	_spr.frame = RigHeadCard.OCT_FRAME[o] * COLS + _column(host, s)
	_spr.flip_h = RigHeadCard.OCT_FLIP[o] == 1
	_spr.global_rotation = 0.0
	_spr.global_scale = Vector2(s, s / vm.ground_k())
	return true


static func path_of(art: String, name: String) -> String:
	return ART_DIR.path_join(art).path_join(name + "_walk8.png")


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
	if px / SimClock.TICK_DT < WALK_FROM_MPS * SimConst.PX_PER_M:
		_still += 1  # a frame with no sim step (a hit-stop, a fast display) keeps the stride
		_col = STAND_COL if _still > STILL_FRAMES else _col
		return _col
	_still = 0
	var cycle: float = maxf(cycle_cell * s, px / SimClock.TICK_DT / MAX_CYCLES_S)
	var back: bool = (
		moved.normalized().dot(Vector2.from_angle(host.global_rotation)) < BACKPEDAL_DOT
	)
	_phase = fposmod(_phase + px / cycle * (-1.0 if back else 1.0), 1.0)
	_col = mini(int(_phase * COLS), COLS - 1)
	return _col


func _rebuild(host: Node2D, parts: Array[Sprite2D], vm: ViewMode) -> void:
	if _spr != null:
		_spr.queue_free()
		_spr = null
	_art = vm.art
	var path: String = path_of(_art, card_name)
	if vm.cards and _art != "" and ResourceLoader.exists(path):
		_spr = Sprite2D.new()
		_spr.name = &"ghost_drawn"
		_spr.texture = load(path) as Texture2D
		_spr.hframes = COLS
		_spr.vframes = ROWS
		_spr.centered = false
		var cell: Vector2 = Vector2(
			_spr.texture.get_width() / float(COLS), _spr.texture.get_height() / float(ROWS)
		)
		_spr.offset = Vector2(-cell.x * 0.5, PAD_PX - cell.y)
		_spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		host.add_child(_spr)
	for p: Sprite2D in parts:
		p.visible = _spr == null
