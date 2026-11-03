class_name BloodBatch
extends RefCounted
## Batched draws for the blood (lane d5-combat, the riot budget): a pool is a cached unit ring
## (centre + BloodMarks.ring at radius 1) drawn as a pre-indexed triangle fan, so no polygon is
## re-triangulated each redraw (draw_colored_polygon cost ~100 us a ring: 4.8 ms for 16 pools);
## the droplets in the air go out as a few draw_multiline calls bucketed by width instead of a
## draw_line + draw_circle each (~5 ms for a 280-drop spray). Static, stateless, render only.

const WIDTH_STEP: float = 0.5

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


## The droplets in the air: a streak `trail` ticks long behind each live drop, `pad` px wider
## (an ink casing when pad > 0), bucketed by width into draw_multiline calls.
static func drops(ci: CanvasItem, fx: Array, trail: float, c: Color, pad: float) -> void:
	var pos: PackedVector2Array = fx[0]
	var vel: PackedVector2Array = fx[1]
	var size: PackedFloat32Array = fx[2]
	var life: PackedInt32Array = fx[3]
	var buckets: Dictionary[int, PackedVector2Array] = {}
	for i: int in pos.size():
		if life[i] <= 0:
			continue
		var w: float = size[i] * 2.0 + pad
		var b: int = maxi(1, roundi(w / WIDTH_STEP))
		var tail: Vector2 = vel[i] * trail
		if tail.length() < w * 0.5:
			tail = (vel[i].normalized() if vel[i] != Vector2.ZERO else Vector2.RIGHT) * w * 0.5
		if not buckets.has(b):
			buckets[b] = PackedVector2Array()
		var seg: PackedVector2Array = buckets[b]
		@warning_ignore("return_value_discarded")
		seg.append(pos[i] - tail)
		@warning_ignore("return_value_discarded")
		seg.append(pos[i])
		buckets[b] = seg
	for b: int in buckets:
		ci.draw_multiline(buckets[b], c, b * WIDTH_STEP)


static func _fan_of(n: int) -> PackedInt32Array:
	if _fan.size() == n * 3:
		return _fan
	_fan = PackedInt32Array()
	for k: int in n:
		@warning_ignore("return_value_discarded")
		_fan.append_array([0, 1 + k, 1 + (k + 1) % n])
	return _fan
