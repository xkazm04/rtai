class_name ServoWingBand
extends RefCounted
## The target's rack base: a hazard-striped ledge along each wing's front edge (the sheet's top
## view runs copper and ink stripes under the bays). The wing art has striped side panels only.
## Drawn by ServoRig in the wing's own art space (ART_PPM px, +y forward, x mirrored per side),
## right after the wing texture, so it turns, flips and shakes with the wing. Render only.
## Copper, not vermilion: vermilion is for danger and objectives (the standing palette verdict).

## false = no band (the it9 wing).
const ON: bool = true
## Art px: the ledge's depth, how far it overlaps the wing's front bar, its inset from the
## wing's ends, and the stripe period (half copper, half ink).
const DEPTH_PX: float = 22.0
const OVERLAP_PX: float = 4.0
const INSET_PX: float = 14.0
const PERIOD_PX: float = 22.0
const COPPER: Color = Color8(196, 112, 60)
const INK: Color = Color8(27, 22, 26)
## The copper share of each stripe period.
const COPPER_K: float = 0.6


## `front_y`: the wing's front edge (art px), `half_w`: the wing's half width (art px).
static func draw(c: CanvasItem, front_y: float, half_w: float, tint: Color) -> void:
	if not ON:
		return
	var x0: float = -half_w + INSET_PX
	var x1: float = half_w - INSET_PX
	var y0: float = front_y - OVERLAP_PX
	var y1: float = y0 + DEPTH_PX
	c.draw_rect(Rect2(x0 - 2.0, y0 - 2.0, x1 - x0 + 4.0, DEPTH_PX + 4.0), INK * tint)
	var x: float = x0 + 2.0
	while x + DEPTH_PX + PERIOD_PX * COPPER_K <= x1:  # whole stripes only (no clipped slivers)
		var pts: PackedVector2Array = PackedVector2Array(
			[
				Vector2(x, y1),
				Vector2(x + DEPTH_PX, y0),
				Vector2(x + DEPTH_PX + PERIOD_PX * COPPER_K, y0),
				Vector2(x + PERIOD_PX * COPPER_K, y1)
			]
		)
		c.draw_colored_polygon(pts, COPPER * tint)
		x += PERIOD_PX
