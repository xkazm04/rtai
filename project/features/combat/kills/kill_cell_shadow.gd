class_name KillCellShadow
extends Node2D
## n17 npc-react (DEFECTS 18): a living street person stands on RigCastShadows' soft contact
## ellipse, which it draws for live rigs only; on the kill tick the rig is dead and a death's drawn
## cells (KillFallCells: the fall grid or the death's own frames) stood on bare street until the
## corpse. This child of the cells draws the same ellipse, the same size and slide, behind them
## while the drawn figure still stands (the rows before the lying run), none once it lies (the
## corpse's own ground reads). Render only. ON false = the before (no shadow under the cells).

const ON: bool = true

## The ellipse's radius and slide in global px, fixed at the cut from the living rig's hip.
var radius_px: float = 0.0
var slide_px: Vector2 = Vector2.ZERO
## The first frame row whose figure lies (from it on no shadow).
var lying_from: int = 1 << 20


## Adds the shadow under `cells` (a death's grid) when the view draws contact shadows; else null.
static func attach(rig: CutRig, cells: Sprite2D) -> KillCellShadow:
	var view: ViewMode = ViewMode.shared()
	if not ON or cells == null or view.cast_k <= 0.0:
		return null
	if view.cast_k >= RigCastShadows.CONTACT_BELOW_K:
		return null
	var hip: float = RigCastShadows.hip_px(rig)
	var s: KillCellShadow = KillCellShadow.new()
	s.name = "cell_shadow"
	s.show_behind_parent = true
	s.radius_px = hip * RigCastShadows.CONTACT_R_HIPS
	s.slide_px = view.cast_dir() * hip * RigCastShadows.CONTACT_SLIDE_HIPS
	s.lying_from = lying_row(cells)
	cells.add_child(s)
	return s


## The first lying row of a grid: a FIT grid's trailing run of rows at 1.0 (the corpse as drawn),
## else the last row (the fall grids and unfitted deaths end lying).
static func lying_row(cells: Sprite2D) -> int:
	var last: int = maxi(cells.vframes - 1, 0)
	var key: String = KillDeathCells.key_of(cells)
	if not KillDeathCells.FIT_K.has(key):
		return last
	var ks: Array = KillDeathCells.FIT_K[key]
	var at: int = ks.size()
	while at > 0:
		var k: float = ks[at - 1]
		if k < 1.0:
			break
		at -= 1
	return mini(at, last) if at < ks.size() else last


## True while the drawn figure stands (its row is before the lying run).
func stands() -> bool:
	var cells: Sprite2D = get_parent() as Sprite2D
	return cells != null and cells.frame_coords.y < lying_from


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not stands():
		return
	var g: Vector2 = global_transform.get_scale().abs()
	if g.x <= 0.0 or g.y <= 0.0:
		return
	var at: Vector2 = slide_px / g
	for ring: Vector2 in RigCastShadows.CONTACT_RINGS:
		var r: float = radius_px * ring.x
		var pts: PackedVector2Array = RigCastShadows.contact_ellipse(Vector2.ZERO, r)
		for i: int in pts.size():
			pts[i] = at + pts[i] / g
		draw_colored_polygon(pts, Color(RigCastShadows.SHADOW, ring.y))
