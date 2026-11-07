class_name PropBox
extends RefCounted
## A flat top-down box sprite stood up as two layers under a tilt (n8 city, brief item 3): its own
## art as the top, lifted by the box's height, over a front face cut from the art's south band
## (darkened, ink-ruled) and a ground shadow. For quest art with no sheet (the TUCK-IN crates and
## their stencil). Straight down it is exactly the flat draw it replaces. Render only.

## Box heights (m) by sprite name; a name not here draws flat.
const HEIGHT_M: Dictionary[String, float] = {"tuckin_crate": 1.0, "tuckin_crate_hit": 1.0}
## The art's south band (fraction of its height) stretched over the front face.
const BAND: float = 0.22
const FRONT_TINT: Color = Color(0.68, 0.64, 0.6)
const INK: Color = Color(0.090, 0.075, 0.106)
const SHADOW: Color = Color(0.090, 0.075, 0.106, 0.35)
## The ground shadow's offset per metre of height (m, down-right as the cast shadows).
const SHADOW_OFF_M: Vector2 = Vector2(0.3, 0.2)


## Draws `name`'s art `tex` on ground rect `r` (ci's local px, `px_per_m` px per metre): flat when
## the view is straight down or the name has no height, else as a standing box.
static func draw_on(
	ci: CanvasItem, name: String, tex: Texture2D, r: Rect2, px_per_m: float
) -> void:
	var h_m: float = HEIGHT_M[name] if HEIGHT_M.has(name) else 0.0
	var lift: float = -ViewMode.shared().lift_px(h_m).y
	lift *= px_per_m / SimConst.PX_PER_M
	if lift <= 0.0:
		ci.draw_texture_rect(tex, r, false)
		return
	ci.draw_rect(Rect2(r.position + SHADOW_OFF_M * h_m * px_per_m, r.size), SHADOW)
	var front: Rect2 = front_rect(r, lift)
	var size: Vector2 = tex.get_size()
	var src: Rect2 = Rect2(0.0, size.y * (1.0 - BAND), size.x, size.y * BAND)
	ci.draw_texture_rect_region(tex, front, src, FRONT_TINT)
	ci.draw_rect(front, INK, false, 2.0)
	ci.draw_texture_rect(tex, Rect2(r.position - Vector2(0.0, lift), r.size), false)


## The front face: from the lifted top's south edge down to the footprint's south edge.
static func front_rect(r: Rect2, lift: float) -> Rect2:
	return Rect2(r.position.x, r.end.y - lift, r.size.x, lift)
