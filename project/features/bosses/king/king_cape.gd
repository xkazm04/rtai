class_name KingCape
extends RefCounted
## King's vermilion cape from straight above (boss_king.jpg's 90-degree panel): a fan from the
## shoulders back to a hem that folds (alternate hem points in and out, ink fold lines from the
## collar into the troughs) under an ermine border (cream fur, an ink outer edge, ink tail spots).
## It moves, render only, on the fight's tick: a slow sway of the hem, gathered in through the
## charge's and ram's tell, flared back through their active window (follow-through); the press
## slam's leap does the same and the hem lands wide with the shockwave, then settles. FOLDS 0 =
## the it12 flat trapezoid with a plain cream band.

const FUR: Color = Color("#EFE6D2")
## Hem points across the fan, and how far a fold's trough sits in from its crest (m per k).
const FOLDS: int = 4
const FOLD_DEPTH: float = 0.09
const FOLD_INK_W: float = 0.03
## A fold line starts this far out from the collar (0 = from the collar: spokes, it13a).
const FOLD_FROM: float = 0.3
const FUR_W: float = 0.16
const SPOT_R: float = 0.035
## The idle sway: hem amplitude (m per k) and its period (ticks, 60 Hz).
const SWAY_M: float = 0.05
const SWAY_TICKS: float = 96.0
## Hem reach through a charging attack's tell (gathered) and active window (flared).
const GATHER_K: float = 0.88
const FLARE_K: float = 1.22
const CHARGING: Array[StringName] = [&"charge", &"ram", &"press_slam"]
## The slam's landing: the hem spreads this much wider with the shockwave (1.0 = no beat, it14a).
const LAND_SPREAD_K: float = 1.14
const LANDING: Array[StringName] = [&"press_slam"]
## The ease into each reach (ticks): gathered over this, flared over half, settled over twice.
const EASE_TICKS: float = 12.0
## View lab: under a tilt or top_lift the cape drapes: the shoulders stand DRAPE_SHOULDER_M up,
## each point lower the further back it lies, the hem on the ground past DRAPE_BACK_M.
const DRAPE_SHOULDER_M: float = 1.6
const DRAPE_BACK_M: float = 1.6


## The cape at `at` (px), facing +x, scaled `p` px per unit, for `fight` now; `up` = the local
## lift per metre of height (ZERO straight down: the cape lies flat, untouched).
static func draw(
	ci: CanvasItem, at: Vector2, p: float, fight: BossFight, up: Vector2 = Vector2.ZERO
) -> void:
	var hem: PackedVector2Array = _hem(at, p, fight)
	var shoulder_l: Vector2 = at + Vector2(0.1, -0.7) * p
	var shoulder_r: Vector2 = at + Vector2(0.1, 0.7) * p
	if up != Vector2.ZERO:
		hem = _draped(hem, at, p, up)
		shoulder_l += up * DRAPE_SHOULDER_M
		shoulder_r += up * DRAPE_SHOULDER_M
	var poly: PackedVector2Array = PackedVector2Array([shoulder_l]) + hem
	poly += PackedVector2Array([shoulder_r])
	ci.draw_colored_polygon(poly, Ink.VERMILION)  # the King's cape: vermilion by verdict
	if FOLDS <= 0:
		ci.draw_polyline(poly, FUR, FUR_W * p)
		return
	for i: int in range(1, hem.size() - 1, 2):  # a fold line from the collar into each trough
		var root: Vector2 = at + Vector2(-0.2, (hem[i].y - at.y) / p * 0.35) * p
		var fold: Vector2 = hem[i] - root
		ci.draw_line(root + fold * FOLD_FROM, root + fold * 0.9, Ink.INK, maxf(FOLD_INK_W * p, 1.0))
	ci.draw_polyline(poly, Ink.INK, FUR_W * p + 3.0)
	ci.draw_polyline(poly, FUR, FUR_W * p)
	for i: int in hem.size() - 1:  # the ermine's ink tails along the hem
		ci.draw_circle(hem[i].lerp(hem[i + 1], 0.5), maxf(SPOT_R * p, 1.2), Ink.INK)


## The hem from the left shoulder's back corner round to the right's: 2 * FOLDS + 1 points on
## the it12 outline's curve, troughs pulled in, swayed and stretched by the attack's beat.
static func _hem(at: Vector2, p: float, fight: BossFight) -> PackedVector2Array:
	var n: int = maxi(FOLDS, 1) * 2
	var reach: float = _reach(fight)
	var spread: float = _spread(fight)
	var tick: float = float(fight.now()) if fight != null else 0.0
	var out: Array[Vector2] = []
	for i: int in n + 1:
		var s: float = float(i) / float(n) * 2.0 - 1.0  # -1 left .. 1 right
		var back: float = 1.1 + 0.2 * (1.0 - s * s)
		if FOLDS > 0 and i % 2 == 1:
			back -= FOLD_DEPTH
		var sway: float = SWAY_M * sin(TAU * tick / SWAY_TICKS + s * 1.6) if FOLDS > 0 else 0.0
		out.append(at + Vector2(0.1 - back * reach, s * 0.95 * spread + sway * absf(s)) * p)
	return PackedVector2Array(out)


## Each hem point lifted by how far forward it lies: DRAPE_SHOULDER_M at the shoulders' line,
## falling linearly to 0 at DRAPE_BACK_M behind it (it5's flat-cape drape: corners ~0.4 m).
static func _draped(
	hem: PackedVector2Array, at: Vector2, p: float, up: Vector2
) -> PackedVector2Array:
	var out: PackedVector2Array = hem.duplicate()
	for i: int in out.size():
		var back: float = (at.x + 0.1 * p - out[i].x) / (DRAPE_BACK_M * p)
		var k: float = 1.0 - clampf(back, 0.0, 1.0)
		out[i] += up * DRAPE_SHOULDER_M * k
	return out


static func _reach(fight: BossFight) -> float:
	if FOLDS <= 0 or fight == null or fight.attack == null:
		return 1.0
	if not CHARGING.has(fight.attack.id):
		return 1.0
	var t: float = float(fight.t)
	match fight.state:
		BossFight.State.WINDUP:  # anticipation: drawn in over the tell's first EASE_TICKS
			return lerpf(1.0, GATHER_K, smoothstep(0.0, EASE_TICKS, t))
		BossFight.State.ACTIVE:  # the dash pulls it out behind him
			return lerpf(GATHER_K, FLARE_K, smoothstep(0.0, EASE_TICKS * 0.5, t))
		BossFight.State.RECOVER:  # follow-through: it settles after he stops
			return lerpf(FLARE_K, 1.0, smoothstep(0.0, EASE_TICKS * 2.0, t))
	return 1.0


## The hem's width: wide as the slam lands (his recovery's first tick), easing back over the
## settle; 1.0 otherwise.
static func _spread(fight: BossFight) -> float:
	if FOLDS <= 0 or fight == null or fight.attack == null:
		return 1.0
	if not LANDING.has(fight.attack.id) or fight.state != BossFight.State.RECOVER:
		return 1.0
	return lerpf(LAND_SPREAD_K, 1.0, smoothstep(0.0, EASE_TICKS * 2.0, float(fight.t)))
