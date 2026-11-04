class_name WeaponFxElectro
extends RefCounted
## weapon-art's electro cells for gunplay's chain arcs and stunned humans (FightAreasArt asks these
## first; false = not drawn, so gunplay's procedural zigzags draw instead). Render-only: reads the
## sim's arc ends and stun state, no RNG, no delta. `--weapon-fx=shapes` turns them off.

## The spark where a chain arc lands, and the daze sparks, in cell scale.
const SPARK_K: float = 1.6
const STUN_SPARK_K: float = 1.3
## Two sparks circle a stunned head this far out (m), this high above the body centre (m).
const STUN_RING_M: float = 0.4
const STUN_LIFT_M: float = 0.55


## The jagged paper arc from `a` to `b` (m) with a spark where it lands; frame by `phase`.
static func chain(ci: CanvasItem, a: Vector2, b: Vector2, phase: int) -> bool:
	if not WeaponFxArt.enabled or a.distance_to(b) < 0.05:
		return false
	var span_m: float = a.distance_to(b)
	var k: float = WeaponFxArt.cell_scale()
	var span: float = span_m * Ink.PX_PER_M / (WeaponFxArt.ARC_SPAN_PX * k)
	var ang: float = (b - a).angle()
	WeaponFxArt.draw_cell(ci, &"arc", phase % 3, a, ang, Vector2(span, 1.0))
	WeaponFxArt.draw_cell(
		ci, &"spark", (phase + 1) % 3, b, float(phase) * 0.7, Vector2.ONE * SPARK_K
	)
	return true


## Two sparks circling a stunned human's head (the cartoon daze), `tick` turns them.
static func stun(ci: CanvasItem, at: Vector2, tick: int) -> bool:
	if not WeaponFxArt.enabled:
		return false
	var head: Vector2 = at + Vector2(0.0, -STUN_LIFT_M)
	for i: int in 2:
		var ang: float = float(tick) * 0.25 + PI * float(i)
		var p: Vector2 = head + Vector2.from_angle(ang) * STUN_RING_M
		WeaponFxArt.draw_cell(ci, &"spark", (tick / 3 + i) % 3, p, ang, Vector2.ONE * STUN_SPARK_K)
	return true
