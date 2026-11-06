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
## The hood cannon's mount along the car (fraction of its length from the middle): the code roof's
## 0.2, or the roof art's laurel mount ring (car_roof.png: the ring's hole at 0.33).
const MOUNT_K: float = 0.2
const ART_MOUNT_K: float = 0.33
## The throne card's width face-on (m: it frames the 1.5x bust, the sheet's throne rising over
## his shoulders), side-on (its depth over its width), and its foot behind the seat (m).
const THRONE_W_M: float = 3.0
const THRONE_SIDE_K: float = 0.7
const THRONE_BACK_M: float = 0.3
## The end walls' painted bumper rows (m from the ground: car_front/car_rear rows 98-126) stand
## BUMPER_PROUD_M past the nose and the tail, the art extruded, so the ends keep a proud gilded lip
## (KingCarTrim.bumpers' code bars are not drawn over the art). 0 = flush walls.
const BUMPER_Z_M: Vector2 = Vector2(0.1, 0.4)
const BUMPER_PROUD_M: float = 0.18
## The hood cannon's barrel from art (cannon.png, cut from the sheet's side view): its width (m).
const CANNON_W_M: float = 0.7

const QUAD_UV: PackedVector2Array = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]

static var _tex: Dictionary[String, Texture2D] = {}


## Draws the stack from art and returns true; false (nothing drawn) when this pitch has no walls.
static func draw(ci: CanvasItem, at: Vector2, heading: float, l: float, w: float) -> bool:
	var view: ViewMode = ViewMode.shared()
	var side: Texture2D = _wall(view.art_pitch(), "car_side")
	var front: Texture2D = _wall(view.art_pitch(), "car_front")
	var rear: Texture2D = _wall(view.art_pitch(), "car_rear")
	if side == null or front == null or rear == null:
		return false
	var origin: Vector2 = ci.get_global_transform() * at
	var body: Rect2 = Rect2(-l * 0.5, -w * 0.5, l, w)
	for i: int in SLICES:  # the ink pass: the stack's outline, the bumpers' past the ends
		_at(ci, at, heading, view.lift_at(origin, _z(i)))
		var b: float = _proud(i)
		ci.draw_rect(body.grow_individual(b, 0.0, b, 0.0).grow(INK_PX), Ink.INK)
	var t: float = BAND_M * Ink.PX_PER_M
	for i: int in SLICES:
		var lift: Vector2 = view.lift_at(origin, _z(i))
		var k: float = 1.0 - float(i) / float(SLICES - 1)  # the wall row: 0 at the roof line
		var b: float = _proud(i)
		_at(ci, at, heading, lift)
		_band(ci, side, Rect2(-l * 0.5, -w * 0.5, l, t), k)
		_band(ci, side, Rect2(-l * 0.5, w * 0.5 - t, l, t), k)
		_at(ci, at, heading + PI * 0.5, lift)  # the ends: x across the car, -y toward the nose
		_band(ci, front, Rect2(-w * 0.5, -l * 0.5 - b, w, t + b), k)
		_band(ci, rear, Rect2(-w * 0.5, l * 0.5 - t, w, t + b), k)
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


## How far slice `i`'s end bands stand past the nose and the tail (px): the bumpers' rows only.
static func _proud(i: int) -> float:
	var z: float = _z(i)
	var bumper: bool = z >= BUMPER_Z_M.x and z <= BUMPER_Z_M.y
	return BUMPER_PROUD_M * Ink.PX_PER_M if bumper else 0.0


## The hood cannon from `tail` to `tip` (car px): the barrel from art for this pitch (breech at the
## strip's left) on KingCarTrim's swivel mount; with no strip, KingCarTrim's drawn barrel.
static func cannon(ci: CanvasItem, tail: Vector2, tip: Vector2) -> void:
	var tex: Texture2D = _wall(ViewMode.shared().art_pitch(), "cannon")
	if tex == null:
		KingCarTrim.cannon(ci, tail, tip)
		return
	var a: Vector2 = tip - tail
	var n: Vector2 = a.normalized().orthogonal() * CANNON_W_M * 0.5 * Ink.PX_PER_M
	ci.draw_circle(tail + a * 0.2, 17.0, Ink.INK)  # the swivel mount under the breech
	ci.draw_circle(tail + a * 0.2, 14.5, KingCarTrim.GOLD_DARK)
	var quad: PackedVector2Array = PackedVector2Array([tail + n, tip + n, tip - n, tail - n])
	ci.draw_polygon(quad, PackedColorArray([Color.WHITE]), QUAD_UV, tex)


## Where the hood cannon stands (and its coins fly from): on the roof art's ring when drawn.
static func mount_k() -> float:
	var view: ViewMode = ViewMode.shared()
	var art: bool = view.has_lift() and _wall(view.art_pitch(), "car_roof") != null
	return ART_MOUNT_K if art else MOUNT_K


## The roof from art for this pitch over `body` (car px, nose +x); false when it has none.
static func roof(ci: CanvasItem, body: Rect2) -> bool:
	var tex: Texture2D = _wall(ViewMode.shared().art_pitch(), "car_roof")
	if tex == null:
		return false
	ci.draw_rect(body.grow(INK_PX), Ink.INK)
	ci.draw_texture_rect(tex, body, false)
	return true


## The empty throne as an upright card at the seat `at` (car px; `up` = the car-local lift per
## metre): the back when the car's tail points down the screen, else the front, its width eased
## to THRONE_SIDE_K side-on. Drawn as a textured quad in the car's frame, upright on the screen.
static func throne(ci: CanvasItem, at: Vector2, p: float, up: Vector2) -> bool:
	var view: ViewMode = ViewMode.shared()
	var back: bool = up.x > 0.0  # the tail (-x) faces the camera (down the screen)
	var tex: Texture2D = _wall(view.art_pitch(), "throne_back" if back else "throne_front")
	if tex == null or up == Vector2.ZERO:
		return false
	var u: Vector2 = up.normalized()
	var side: Vector2 = u.rotated(PI * 0.5)  # the screen's right, in the car's frame
	var face: float = lerpf(THRONE_SIDE_K, 1.0, absf(u.x))
	var half: float = THRONE_W_M * 0.5 * p * face
	var tall: Vector2 = u * (half * 2.0 * tex.get_height() / tex.get_width() / view.ground_k())
	var foot: Vector2 = at - Vector2(THRONE_BACK_M * p, 0.0)
	var quad: PackedVector2Array = PackedVector2Array(
		[
			foot - side * half + tall,
			foot + side * half + tall,
			foot + side * half,
			foot - side * half
		]
	)
	ci.draw_polygon(quad, PackedColorArray([Color.WHITE]), QUAD_UV, tex)
	return true


## The wall strip for a pitch (null: none). One lookup per path; `top` never asks (no lift).
static func _wall(pitch_deg: float, name: String) -> Texture2D:
	var path: String = DIR % [roundi(pitch_deg), name]
	if not _tex.has(path):
		_tex[path] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _tex[path]
