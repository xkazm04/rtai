class_name KillExitWound
extends Node2D
## n16 kills-polish item 3 (asset lane A6, it434; KILLS: the hand cannon's blowback tore nothing):
## the hand cannon round leaves a drawn exit wound in the thrown body's chest: torn cloth flaps,
## red meat, rib arcs and the spine's knuckles, a spatter tongue out along the shot. A child of the
## body group, so it tumbles with the body and lies with it. Fresh at the kill; a street victim's
## wound dries to the dark matte frame over DRY_TICKS (a cop's keeps its navy flaps, fresh).
## Render only, no RNG. Row `wound_m` (the hole's width, 0 = none); `--exit-wound=off` = the
## before.

const ART: Texture2D = preload("res://features/combat/weapons/art/gore/exit_wound.png")
## The hole's width in the packed cell (tools/art/exit_wound_cells.py) and its centre's offset
## from the cell's centre (the tongue runs out to +x, so the hole sits left of centre).
const ART_HOLE_PX: float = 32.5
const ART_HOLE_AT: Vector2 = Vector2(-7.0, -4.0)
const FRESH: int = 0
const DRIED: int = 1
const FRESH_COP: int = 2
const DRY_TICKS: int = 240
## Where on the figure (KillFigure: y -1 head .. 1 feet): the chest.
const CHEST: Vector2 = Vector2(0.0, -0.4)
## The p55 view: the drawing squashed (asset lane: the p55 cells are the p70 ones at 0.8 high).
const P55_SQUASH: float = 0.8

static var _off: int = -1

var kills: SignatureKills = null
var tick0: int = 0
var cop: bool = false
var hole_px: float = 8.0


## True under `--exit-wound=off` (no wound: the before).
static func off() -> bool:
	if _off < 0:
		_off = 1 if ArenaArgs.parse().text("--exit-wound") == "off" else 0
	return _off == 1


## Puts the row's wound on `body` (a rig's whole-body group) at its chest, the tongue along `dir`
## (the body turns from this pose on, so the wound turns with it), the hole `wound_m` wide at
## `ppm`. Returns the wound (null: none); the caller sets its `kills` and `tick0`.
static func attach(
	body: Node2D, rig: CutRig, row: SignatureKill, dir: Vector2, ppm: float
) -> KillExitWound:
	if body == null or rig == null or row.wound_m <= 0.0 or off():
		return null
	var w: KillExitWound = KillExitWound.new()
	w.cop = StreetWalkerCards.row_of(rig).begins_with("cop/")
	w.hole_px = row.wound_m * ppm
	var b: Rect2 = KillFigure.cached(body, 8.0)
	w.position = b.get_center() + CHEST * b.size * 0.5
	w.rotation = dir.angle() if dir != Vector2.ZERO else 0.0
	if ViewMode.shared().art == "p55":
		w.scale = Vector2(1.0, P55_SQUASH)
	w.z_index = 35  # over the body's own parts (they reach +30)
	body.add_child(w)
	return w


## The cell frame and the blend into the next at `age` ticks: (frame, next, mix).
func frames(age: int) -> Vector3:
	if cop:
		return Vector3(FRESH_COP, FRESH_COP, 0.0)
	return Vector3(FRESH, DRIED, clampf(float(age) / DRY_TICKS, 0.0, 1.0))


func _process(_delta: float) -> void:
	if kills != null and kills.tick - tick0 <= DRY_TICKS + 1:
		queue_redraw()


func _draw() -> void:
	var cell: float = ART.get_height()
	var side: float = cell * hole_px / ART_HOLE_PX
	var at: Rect2 = Rect2(-ART_HOLE_AT * side / cell - Vector2.ONE * side * 0.5, Vector2.ONE * side)
	var f: Vector3 = frames(kills.tick - tick0 if kills else DRY_TICKS)
	draw_texture_rect_region(ART, at, Rect2(cell * f.x, 0.0, cell, cell))
	if f.z > 0.0 and f.y != f.x:
		var mix: Color = Color(1.0, 1.0, 1.0, f.z)
		draw_texture_rect_region(ART, at, Rect2(cell * f.y, 0.0, cell, cell), mix)
