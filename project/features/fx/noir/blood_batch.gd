class_name BloodBatch
extends RefCounted
## Batched draws for the blood (lane d5-combat, the riot budget): a pool is a cached unit ring
## (centre + BloodMarks.ring at radius 1) drawn as a pre-indexed triangle fan, so no polygon is
## re-triangulated each redraw (draw_colored_polygon cost ~100 us a ring: 4.8 ms for 16 pools);
## the droplets in the air go out as a few draw_multiline calls bucketed by width instead of a
## draw_line + draw_circle each (~5 ms for a 280-drop spray). Static, stateless, render only.

const WIDTH_STEP: float = 0.5
## n11 (the owner: the blood read as square chips): how a drop in the air is built, of its width.
## The head is two crossed bars this wide (a round blob at 3 to 8 px), then a neck and a thin tail.
const HEAD_BAR: float = 0.62
const NECK_W: float = 0.5
## The neck's length, of the drop's width; past it the tail runs to the streak's end.
const NECK_LEN: float = 1.4
const TAIL_W: float = 0.22
const PIECE_ENDS: int = 8

static var _fan: PackedInt32Array = PackedInt32Array()


## The unit outline of a pool run out along `flow` with wobble seed `s`: the centre, then the ring.
static func unit_ring(flow: Vector2, s: float) -> PackedVector2Array:
	var out: PackedVector2Array = [Vector2.ZERO]
	out.append_array(BloodMarks.ring(Vector2.ZERO, 1.0, flow, s))
	return out


## A pool at `at`, radius `r`, from its unit ring: [ink keyline,] rim, body, then the sheen arc.
## cols = [body, rim, sheen(, ink)] as BloodMarks.pool.
static func pool(
	ci: CanvasItem,
	at: Vector2,
	r: float,
	unit: PackedVector2Array,
	cols: PackedColorArray,
	ink_px: float
) -> void:
	var item: RID = ci.get_canvas_item()
	var fan: PackedInt32Array = _fan_of(unit.size() - 1)
	var layers: Array[Vector2] = []
	if cols.size() > 3:
		layers.append(Vector2(r * BloodMarks.RIM + ink_px, 3))
	layers.append(Vector2(r * BloodMarks.RIM, 1))
	layers.append(Vector2(r, 0))
	for l: Vector2 in layers:
		ci.draw_set_transform(at, 0.0, Vector2(l.x, l.x))
		RenderingServer.canvas_item_add_triangle_array(item, fan, unit, [cols[int(l.y)]])
	ci.draw_set_transform(Vector2.ZERO)
	if r > 6.0:
		var c: Vector2 = at + Vector2(-0.3, -0.35) * r
		ci.draw_arc(c, r * 0.32, PI * 1.02, PI * 1.48, 8, cols[2], maxf(1.0, r * 0.07))


## The droplets in the air: a rounded head on a tapering tail `trail` ticks long, `pad` px wider
## (an ink casing when pad > 0), bucketed by width into draw_multiline calls.
static func drops(ci: CanvasItem, fx: Array, trail: float, c: Color, pad: float) -> void:
	var pos: PackedVector2Array = fx[0]
	var vel: PackedVector2Array = fx[1]
	var size: PackedFloat32Array = fx[2]
	var life: PackedInt32Array = fx[3]
	var buckets: Dictionary[int, PackedVector2Array] = {}
	var out: PackedVector3Array = PackedVector3Array()
	@warning_ignore("return_value_discarded")
	out.resize(PIECE_ENDS)
	for i: int in pos.size():
		if life[i] <= 0:
			continue
		var w: float = size[i] * 2.0 + pad
		var n: int = _pieces(out, pos[i], vel[i] * trail, w)
		for e: int in range(0, n, 2):
			var b: int = maxi(1, roundi(out[e].z / WIDTH_STEP))
			if not buckets.has(b):
				buckets[b] = PackedVector2Array()
			var seg: PackedVector2Array = buckets[b]
			@warning_ignore("return_value_discarded")
			seg.append(Vector2(out[e].x, out[e].y))
			@warning_ignore("return_value_discarded")
			seg.append(Vector2(out[e + 1].x, out[e + 1].y))
			buckets[b] = seg
	for b: int in buckets:
		ci.draw_multiline(buckets[b], c, b * WIDTH_STEP, true)


## The drop's pieces as segment ends (x, y, width), in pairs: two crossed bars for a round head at
## `at`, then a neck and a tail thinning back along `tail`. Tests read this.
static func drop_segments(at: Vector2, tail: Vector2, w: float) -> Array[Vector3]:
	var out: PackedVector3Array = PackedVector3Array()
	@warning_ignore("return_value_discarded")
	out.resize(PIECE_ENDS)
	var res: Array[Vector3] = []
	for i: int in _pieces(out, at, tail, w):
		res.append(out[i])
	return res


static func _pieces(out: PackedVector3Array, at: Vector2, tail: Vector2, w: float) -> int:
	var along: float = tail.length()
	var dir: Vector2 = tail / along if along > 0.001 else Vector2.RIGHT
	var across: Vector2 = dir.orthogonal()
	var half: float = w * 0.5
	var bar: float = w * HEAD_BAR
	_end(out, 0, at - dir * half, bar)
	_end(out, 1, at + dir * half, bar)
	_end(out, 2, at - across * half, bar)
	_end(out, 3, at + across * half, bar)
	if along <= half:
		return 4
	var neck: float = minf(along, w * NECK_LEN)
	_end(out, 4, at - dir * (half * 0.5), w * NECK_W)
	_end(out, 5, at - dir * neck, w * NECK_W)
	if along <= neck:
		return 6
	_end(out, 6, at - dir * neck, w * TAIL_W)
	_end(out, 7, at - tail, w * TAIL_W)
	return PIECE_ENDS


static func _end(out: PackedVector3Array, i: int, p: Vector2, width: float) -> void:
	out[i] = Vector3(p.x, p.y, width)


static func _fan_of(n: int) -> PackedInt32Array:
	if _fan.size() == n * 3:
		return _fan
	_fan = PackedInt32Array()
	for k: int in n:
		@warning_ignore("return_value_discarded")
		_fan.append_array([0, 1 + k, 1 + (k + 1) % n])
	return _fan
