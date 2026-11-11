class_name KillTorchArt
extends RefCounted
## The molotov's death (lane kills-new, style `torch`), render only: the spirit soaked into his
## clothes keeps burning on him. Unlike the flamethrower's char-and-crumble (burn_char) he does not
## stop and char where he stands: he drops to his knees mid-run (the pose track's squash), folds
## face down along the run (his drawn fall grid, cells_at) and the flames go on licking over him
## until `burn_to` (row fx), shrinking from `fade_from`; smoke rises off the body after
## (KillCookArt.smoke). Flame tongues: amber with a cream core and an ink line, `tongues` of them
## up his figure while he kneels, along the body once he lies. Under --reduced-motion they hold
## their height (no flicker). His own drawn cells (KillDeathCells) carry flames; the tongues
## flicker over them, lower (`cells_flame_m`). No blood. No RNG: shapes from KillNewStyles.h.

const FLAME: Color = Color("#E9A23B")
const CORE: Color = Color("#F4E3B5")


static func draw(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	var to: int = roundi(d.extra.num("burn_to", 180.0))
	if age >= to:
		KillCookArt.smoke(ci, d, age - to)
		return
	var from: float = d.extra.num("fade_from", 120.0)
	var k: float = 1.0 - clampf((float(age) - from) / maxf(1.0, float(to) - from), 0.0, 1.0)
	var lying: bool = age >= roundi(d.extra.num("cells_at", 16.0))
	var n: int = roundi(d.extra.num("tongues", 6.0))
	for t: int in n:
		var u: float = (float(t) + 0.5) / float(n)
		var at: Vector2 = d.feet_px.lerp(d.head_px, 0.15 + 0.75 * u)
		if lying:  # along the drawn body on the street, from the feet past its middle
			at = d.feet_px.lerp(_middle(d), 0.3 + 1.2 * u)
		var flick: float = (
			1.0 if ci.reduced_motion else 0.7 + 0.5 * KillNewStyles.h(d.serial + t, age)
		)
		var tall: float = ci.ppm * flame_m_of(d) * k * flick
		_tongue(ci, at, tall, (KillNewStyles.h(d.serial, t + 600) - 0.5) * 0.5)


## A tongue's full height (m): fx `flame_m`, or on his own drawn cells (which carry drawn flames
## that do not flicker) fx `cells_flame_m`.
static func flame_m_of(d: KillNewStyles.Death) -> float:
	var m: float = d.extra.num("flame_m", 0.32)
	return d.extra.num("cells_flame_m", m) if KillDeathCells.owns(d.cells) else m


## Layer px of the lying body's middle: the drawn cell's alpha centroid (KillCellBody), else
## along the fall.
static func _middle(d: KillNewStyles.Death) -> Vector2:
	if d.cells == null or not d.cells.visible:
		return d.feet_px + d.fall * d.height * 0.45
	return d.xf * (d.cells.transform * KillCellBody.centroid(d.cells))


## One flame tongue rising `tall` px off `at`, leaning `lean` rad.
static func _tongue(ci: KillNewStyles, at: Vector2, tall: float, lean: float) -> void:
	if tall < 1.0:
		return
	var up: Vector2 = Vector2.UP.rotated(lean)
	var side: Vector2 = up.orthogonal() * tall * 0.3
	var outer: PackedVector2Array = PackedVector2Array(
		[
			at - side,
			at - side * 0.4 + up * tall * 0.55,
			at + up * tall,
			at + side * 0.5 + up * tall * 0.4,
			at + side
		]
	)
	KillPoly.fill(ci, outer, FLAME)
	ci.draw_polyline(outer + PackedVector2Array([outer[0]]), Ink.INK, maxf(1.0, ci.ppm * 0.015))
	var core: PackedVector2Array = PackedVector2Array(
		[at - side * 0.45, at + up * tall * 0.55, at + side * 0.45]
	)
	KillPoly.fill(ci, core, CORE)
