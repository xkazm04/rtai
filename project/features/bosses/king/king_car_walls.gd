class_name KingCarWalls
extends RefCounted
## d8 bosses: the throne-car's sprite stack from art under a tilt (render only). Three wall
## strips for a view pitch (art/p<pitch>/car/, tools/art/king_car_walls.py: cut from the approved
## car sheet, our own grille, amber tail lamps): side, front, rear; row 0 = the roof line, the last
## row = the ground. Each of SLICES slices, lifted by its height like KingCarStack's, draws one row
## of each wall as a thin band along its edge of the car's outline, so the stacked bands read as
## the painted walls from any heading (the wheels, drapes and lamps are in the art). A first pass
## inks every slice's outline, so the stack keeps the print's ink edge. A pitch with no strips
## (and `top`, which never lifts) keeps KingCarStack's code slices.
const DIR: String = "res://features/bosses/king/art/p%d/car/%s.png"
## 1.45 m in 40 slices: at 64 px/m under 55 degrees a slice step stays under 2 px (no stair).
const SLICES: int = 40
## A band's depth into the outline (m): deeper than a slice's step, so the bands overlap.
const BAND_M: float = 0.14
const INK_PX: float = 2.5

static var _tex: Dictionary[String, Texture2D] = {}


## Draws the stack from art and returns true; false (nothing drawn) when this pitch has no walls.
static func draw(ci: CanvasItem, at: Vector2, heading: float, l: float, w: float) -> bool:
	var view: ViewMode = ViewMode.shared()
	var side: Texture2D = _wall(view.pitch_deg, "car_side")
	var front: Texture2D = _wall(view.pitch_deg, "car_front")
	var rear: Texture2D = _wall(view.pitch_deg, "car_rear")
	if side == null or front == null or rear == null:
		return false
	var origin: Vector2 = ci.get_global_transform() * at
	var body: Rect2 = Rect2(-l * 0.5, -w * 0.5, l, w)
	for i: int in SLICES:  # the ink pass: the stack's outline
		_at(ci, at, heading, view.lift_at(origin, _z(i)))
		ci.draw_rect(body.grow(INK_PX), Ink.INK)
	var t: float = BAND_M * Ink.PX_PER_M
	for i: int in SLICES:
		var lift: Vector2 = view.lift_at(origin, _z(i))
		var k: float = 1.0 - float(i) / float(SLICES - 1)  # the wall row: 0 at the roof line
		_at(ci, at, heading, lift)
		_band(ci, side, Rect2(-l * 0.5, -w * 0.5, l, t), k)
		_band(ci, side, Rect2(-l * 0.5, w * 0.5 - t, l, t), k)
		_at(ci, at, heading + PI * 0.5, lift)  # the ends: x across the car, -y toward the nose
		_band(ci, front, Rect2(-w * 0.5, -l * 0.5, w, t), k)
		_band(ci, rear, Rect2(-w * 0.5, l * 0.5 - t, w, t), k)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true


## One wall row `k` (0 roof .. 1 ground) stretched over `rect` (the ends draw under a frame turned
## a quarter, so their rows run across the car's width).
static func _band(ci: CanvasItem, tex: Texture2D, rect: Rect2, k: float) -> void:
	var size: Vector2 = tex.get_size()
	var row: float = minf(floorf(k * size.y), size.y - 1.0)
	ci.draw_texture_rect_region(tex, rect, Rect2(0.0, row, size.x, 1.0))


static func _at(ci: CanvasItem, at: Vector2, heading: float, lift: Vector2) -> void:
	ci.draw_set_transform(at + lift, heading, Vector2.ONE)


static func _z(i: int) -> float:
	return KingCarStack.ROOF_M * float(i) / float(SLICES - 1)


## The wall strip for a pitch (null: none). One lookup per path; `top` never asks (no lift).
static func _wall(pitch_deg: float, name: String) -> Texture2D:
	var path: String = DIR % [roundi(pitch_deg), name]
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _tex[path]
