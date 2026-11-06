class_name ServoCrateStack
extends RefCounted
## d8 bosses: a landed CS crate standing up as a box under an angled view (render only). Under a
## tilt the flat crate art read as a floor tile; here the crate is a lifted prism: a cast shadow
## (the arena props' sweep), an ink pass, then SLICES solid kraft slices (dark at the ground,
## lighter toward the lid, the packing tape running down the near face), then the crate art as the
## lid at the crate's height. The slices overlap (a step is under the box's depth), so the face
## reads as one wall. `top` (no lift) keeps ServoDraw's flat crate: draw() draws nothing.

## Slices per crate (0.9 m at 64 px/m under the 55 pitch lifts ~33 px: ~3 px a step).
const SLICES: int = 12
## The box's height as a share of its side (a cube; the sheet's parcels are cubes).
const HEIGHT_K: float = 1.0
## Kraft and tape, sampled from the crate art (crate.png: board 212,151,93; tape 244,205,154).
const KRAFT: Color = Color("#D4975D")
const TAPE: Color = Color("#F4CD9A")
## The face's shade at the ground and just under the lid (the lid itself is the art, unshaded).
const SHADE_LOW: float = 0.58
const SHADE_HIGH: float = 0.8
## The tape's width as a share of the side (the art's tape is ~0.2 of the box).
const TAPE_K: float = 0.2
const INK_PX: float = 1.5


## Draws the crate `side_px` wide centred at `at_px` (canvas px) as a lifted box and returns true;
## false (nothing drawn) when the view has no lift. `px_k` = canvas px per world px.
static func draw(
	ci: CanvasItem, at_px: Vector2, side_px: float, tex: Texture2D, px_k: float
) -> bool:
	var view: ViewMode = ViewMode.shared()
	if not view.has_lift() or tex == null:
		return false
	var h_m: float = side_px / (px_k * SimConst.PX_PER_M) * HEIGHT_K
	var r: Rect2 = Rect2(-side_px * 0.5, -side_px * 0.5, side_px, side_px)
	var c: PackedVector2Array = PackedVector2Array(
		[r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	)
	for j: int in c.size():
		c[j] += at_px
	var off: Vector2 = view.cast_dir() * h_m * view.cast_k * px_k * SimConst.PX_PER_M
	RigCastShadows.sweep(ci, c, off)  # its top thrown down-right, like the arena's props
	return box(ci, at_px, side_px, tex, px_k)


## The box alone (no cast shadow: a falling parcel's shadow is its own), true when drawn.
static func box(
	ci: CanvasItem, at_px: Vector2, side_px: float, tex: Texture2D, px_k: float
) -> bool:
	var view: ViewMode = ViewMode.shared()
	if not view.has_lift() or tex == null:
		return false
	var origin: Vector2 = ci.get_global_transform() * at_px
	var h_m: float = side_px / (px_k * SimConst.PX_PER_M) * HEIGHT_K
	var r: Rect2 = Rect2(-side_px * 0.5, -side_px * 0.5, side_px, side_px)
	var tape: Rect2 = Rect2(-side_px * TAPE_K * 0.5, -side_px * 0.5, side_px * TAPE_K, side_px)
	for i: int in SLICES + 1:  # the ink pass: the prism's outline
		ci.draw_set_transform(at_px + _lift(view, origin, h_m, i) * px_k)
		ci.draw_rect(r.grow(INK_PX), Ink.INK)
	for i: int in SLICES:
		var k: float = float(i) / float(SLICES)
		var shade: float = lerpf(SHADE_LOW, SHADE_HIGH, k)
		ci.draw_set_transform(at_px + _lift(view, origin, h_m, i) * px_k)
		ci.draw_rect(r, _shaded(KRAFT, shade))
		ci.draw_rect(tape, _shaded(TAPE, shade))
	ci.draw_set_transform(at_px + _lift(view, origin, h_m, SLICES) * px_k)
	ci.draw_texture_rect(tex, r, false)
	ci.draw_set_transform(Vector2.ZERO)
	return true


## The lid's offset (world px) for the crate at `origin`, for the font and the shadow callers.
static func lid_lift(ci: CanvasItem, at_px: Vector2, side_px: float, px_k: float) -> Vector2:
	var view: ViewMode = ViewMode.shared()
	if not view.has_lift():
		return Vector2.ZERO
	var h_m: float = side_px / (px_k * SimConst.PX_PER_M) * HEIGHT_K
	return _lift(view, ci.get_global_transform() * at_px, h_m, SLICES) * px_k


static func _lift(view: ViewMode, origin: Vector2, h_m: float, i: int) -> Vector2:
	return view.lift_at(origin, h_m * float(i) / float(SLICES))


static func _shaded(c: Color, k: float) -> Color:
	return Color(c.r * k, c.g * k, c.b * k, 1.0)


## The crate's "CS" stencil on its lid (on the flat crate under `top`: today's draw call).
static func label(ci: CanvasItem, rect: Rect2, px: float, ink: Color, px_k: float) -> void:
	var font_px: int = int(px * 0.32)
	ci.draw_string(
		ThemeDB.fallback_font,
		(
			rect.get_center()
			+ Vector2(-font_px * 0.6, font_px * 0.35)
			+ lid_lift(ci, rect.get_center(), rect.size.x, px_k)
		),
		"CS",
		0,
		-1,
		font_px,
		ink
	)
