class_name KillTrack
extends RefCounted
## The pose track of the n16 deaths (lane kills-new), render only: a whole-body copy (the rig cut,
## or the drawn street card) is tipped, shortened and laid along the street by a few keys from
## its signature_kills.json row (`track`: [tick, lean_deg, squash, tip], linear between keys).
## `lean_deg` tilts the figure along the shot (+ = back, away from the shooter, - = toward him),
## `squash` shortens it (the knees buckling), `tip` (0..1) topples it toward the row's `fall`
## side (forward = onto his face toward the shooter, back = along the shot, side = across it).
## The figure pivots on its feet. No RNG, no sim state: the same tick draws the same pose.

const KEY_TICK: int = 0
const KEY_LEAN: int = 1
const KEY_SQUASH: int = 2
const KEY_TIP: int = 3
## The ground tilt the full tip reaches (a lying figure).
const FLAT: float = PI * 0.5
## A figure never shortens below this share of standing (no zero-size card at a flip).
const MIN_LEN: float = 0.12


## [lean_deg, squash, tip] at `age` ticks (holds the first key before it, the last after it).
static func sample(keys: Array[PackedFloat32Array], age: int) -> Vector3:
	if keys.is_empty():
		return Vector3(0.0, 1.0, 0.0)
	var prev: PackedFloat32Array = keys[0]
	if float(age) <= prev[KEY_TICK]:
		return _v(prev)
	for cur: PackedFloat32Array in keys:
		var t1: float = cur[KEY_TICK]
		if float(age) <= t1:
			var t0: float = prev[KEY_TICK]
			var w: float = 0.0 if t1 == t0 else (float(age) - t0) / (t1 - t0)
			return _v(prev).lerp(_v(cur), w)
		prev = cur
	return _v(prev)


## The fall side as a unit vector on the street (`fall`: forward, back or side; `side` picks
## which side for a sideways fall, +1 or -1).
static func fall_vec(dir: Vector2, fall: StringName, side: float) -> Vector2:
	if fall == &"forward":
		return -dir
	if fall == &"side":
		return dir.orthogonal() * side
	return dir


## The body-local basis (no origin) of a figure `height` px tall leaned and tipped: its head
## vector is the 3D one (cos up + sin along the street) seen in the layer, where a standing
## figure is drawn full height and the street is the layer's plane; the width axis stays square
## to the body. `lie_len`: the lying figure's length on the street (share of standing).
static func basis(dir: Vector2, fall: Vector2, pose: Vector3, lie_len: float) -> Transform2D:
	var g: Vector2 = dir * (pose.x / 90.0) + fall * pose.z
	var amount: float = clampf(g.length(), 0.0, 1.0)
	var along: Vector2 = g.normalized() if amount > 0.0 else Vector2.ZERO
	var a: float = amount * FLAT
	var head: Vector2 = Vector2(0.0, -cos(a)) + along * sin(a) * lie_len
	head *= pose.y
	var length: float = maxf(head.length(), MIN_LEN)
	var up: Vector2 = head.normalized() if head.length() > 0.0001 else Vector2.UP
	return Transform2D(up.rotated(PI * 0.5), -up * length, Vector2.ZERO)


## Lays `lay` (the copy's parent) so the figure pivots on `feet` (body-local px) and slides by
## `slide` (px): the basis `b` turns everything around the feet.
static func lay(node: Node2D, feet: Vector2, b: Transform2D, slide: Vector2) -> void:
	node.transform = Transform2D(b.x, b.y, feet - b.basis_xform(feet) + slide)


## The body-local px of the figure's feet (the bottom centre of its drawn sprites) and its
## height: [feet, height]. A body with no sprites stands 1.7 m at `ppm` on its origin.
static func measure(body: Node2D, ppm: float) -> Array:
	var box: Rect2 = Rect2()
	var first: bool = true
	for s: Sprite2D in _sprites(body):
		var r: Rect2 = _rect_in(body, s)
		box = r if first else box.merge(r)
		first = false
	if first:
		return [Vector2(0.0, 0.85 * ppm), 1.7 * ppm]
	return [Vector2(box.get_center().x, box.end.y), box.size.y]


static func _v(k: PackedFloat32Array) -> Vector3:
	return Vector3(k[KEY_LEAN], k[KEY_SQUASH], k[KEY_TIP])


static func _sprites(n: Node) -> Array[Sprite2D]:
	var out: Array[Sprite2D] = []
	for ch: Node in n.get_children():
		if ch is Sprite2D and (ch as Sprite2D).texture != null and (ch as Sprite2D).visible:
			out.append(ch as Sprite2D)
		out.append_array(_sprites(ch))
	return out


## `s`'s drawn rect in `root`'s local px.
static func _rect_in(root: Node2D, s: Sprite2D) -> Rect2:
	var xf: Transform2D = Transform2D.IDENTITY
	var n: Node = s
	while n != root and n is Node2D:
		xf = (n as Node2D).transform * xf
		n = n.get_parent()
	return xf * s.get_rect()
