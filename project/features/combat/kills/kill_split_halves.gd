class_name KillSplitHalves
extends RefCounted
## The two halves of a blade split (KillSplitFx), render only, no RNG: the half-plane clip mask
## each half is drawn through, and (n16 kills-polish, DEFECTS "blade kills" #2) the topple: once the
## hit-stop (and a saw's grind) ends, each half falls away from the cut about its ground point, so
## a cut man drops in two pieces instead of two upright pieces sliding apart. Row
## split_topple_deg: how far each half turns (0 = the before, upright).

## The fall's length (ticks); it eases in (slow, then fast), as a body tips over.
const TOPPLE_TICKS: int = 16
## A half root's meta: its drawn centre in its own px (KillSplitFx.cut), where its shadow lies.
const SHADOW: StringName = &"split_shadow_at"
## How far from the cut line into its side a half's shadow sits (m).
const SHADOW_IN_M: float = 0.35

static var _white: ImageTexture = null


class Topple:
	extends RefCounted
	var halves: Array[Node2D] = []
	var start: int = 0
	var rad: float = 0.0
	## +1 / -1: the blow's screen side (the way a half falls when the halves are stacked).
	var lean: float = 1.0

	## After KillView placed the halves this frame: side by side (a diagonal cut), each turns away
	## from the other; stacked (the saw's level cut), both fall along the blow, off the attacker.
	func pose(tick: int) -> void:
		var k: float = clampf(float(tick - start) / TOPPLE_TICKS, 0.0, 1.0)
		if k <= 0.0 or halves.size() < 2:
			return
		var gap: Vector2 = halves[0].position - halves[1].position
		for i: int in halves.size():
			var away: float = lean
			if absf(gap.x) > absf(gap.y):
				away = signf(gap.x) * (1.0 if i == 0 else -1.0)
			halves[i].rotation += away * rad * k * k


## n16 kills-polish (DEFECTS 10): where a part's flying shadow goes, in its parent's space: a blade
## half's drawn centre (its root's `SHADOW` meta, set by KillSplitFx.cut) through the root's
## transform, so it follows the topple; any other part: its origin. The top half lay ~1 m from its
## shadow (the root's origin is the body's ground point; the half is drawn above the lifted cut).
static func shadow_at(part: Node2D) -> Vector2:
	if not part.has_meta(SHADOW):
		return part.position
	var local: Vector2 = part.get_meta(SHADOW)
	return part.transform * local


## The topple for `parts`' two halves from tick `start`; null when `deg` is 0 or a half is gone.
static func topple(parts: Array[Node2D], start: int, deg: float, blow_x: float) -> Topple:
	var t: Topple = Topple.new()
	for p: int in [SignatureKill.HALF_A, SignatureKill.HALF_B]:
		if p < parts.size() and parts[p] != null:
			t.halves.append(parts[p])
	if deg <= 0.0 or t.halves.size() < 2:
		return null
	t.start = start
	t.rad = deg_to_rad(deg)
	t.lean = -1.0 if blow_x < 0.0 else 1.0
	return t


## A half-plane (2 m deep) on `side` of the line through `o` along `cut_dir`, clipping its children.
## (A white sprite stretched over the half-plane: a Polygon2D clipped nothing in the 4.7 print.)
static func mask(o: Vector2, cut_dir: Vector2, side: Vector2, view_ppm: float) -> Sprite2D:
	if _white == null:
		var img: Image = Image.create(2, 2, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		_white = ImageTexture.create_from_image(img)
	var m: Sprite2D = Sprite2D.new()
	m.texture = _white
	m.centered = false
	var l: float = 2.0 * view_ppm
	var up: float = 1.0 if side.dot(cut_dir.rotated(PI * 0.5)) > 0.0 else -1.0
	m.rotation = cut_dir.angle()
	m.scale = Vector2(l, l * 0.5 * up)  # the 2 px texture: 2l along the cut, l deep
	m.position = o - cut_dir * l
	m.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	return m
