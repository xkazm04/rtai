class_name CircleFan
extends RefCounted
## Filled circles recorded once and printed as ONE triangle array (perf-city): Godot issues a
## draw call per draw_circle (a polygon command; the canvas batcher never merges those), so a
## corpse soak's ~130 circles were ~130 draw calls, ~1100 a frame in the riot. flush() rebuilds
## the engine's own circle (canvas_item_add_circle: a 64-segment fan around the centre, in
## float32) for every circle in record order, so the pixels are the same as draw_each()'s
## per-circle draw_circle (exact compare: evidence/perf/riot9). Render only.

## The engine's circle (servers/rendering/renderer_canvas_cull.cpp, canvas_item_add_circle).
const SEGMENTS: int = 64
## Cached colour runs kept at most (a fading pool prints a new colour every step).
const RUNS_CAP: int = 64
## False prints every circle with its own draw_circle (the old path, for A/B and evidence).
static var batched: bool = true
static var _unit: PackedVector2Array = PackedVector2Array()
static var _idx: PackedInt32Array = PackedInt32Array()
static var _runs: Dictionary[Color, PackedColorArray] = {}

var centres: PackedVector2Array = PackedVector2Array()
var radii: PackedFloat64Array = PackedFloat64Array()
var colours: PackedColorArray = PackedColorArray()


func add(at: Vector2, r: float, c: Color) -> void:
	@warning_ignore_start("return_value_discarded")
	centres.append(at)
	radii.append(r)
	colours.append(c)
	@warning_ignore_restore("return_value_discarded")


func clear() -> void:
	centres.clear()
	radii.clear()
	colours.clear()


func size() -> int:
	return centres.size()


## One draw_circle per recorded circle, in order (the engine's own path).
func draw_each(ci: CanvasItem) -> void:
	for i: int in centres.size():
		ci.draw_circle(centres[i], radii[i], colours[i])


## Prints the recorded circles on `ci`: one triangle array when `batched`, else draw_each().
func print_on(ci: CanvasItem) -> void:
	if not batched:
		draw_each(ci)
		return
	if centres.is_empty():
		return
	var pts: PackedVector2Array = points()
	var cols: PackedColorArray = colour_runs()
	var idx: PackedInt32Array = indices(centres.size())
	RenderingServer.canvas_item_add_triangle_array(ci.get_canvas_item(), idx, pts, cols)


## Every circle's fan: SEGMENTS + 1 rim points then its centre, in record order (d9-perf: the
## float32 unit rim is computed once, so a point is one multiply and one add, the engine's own
## float32 ops: bit-identical to the per-point _rim() build, test_circle_fan).
func points() -> PackedVector2Array:
	var unit: PackedVector2Array = _unit_rim()
	var pts: PackedVector2Array = PackedVector2Array()
	@warning_ignore("return_value_discarded")
	pts.resize(centres.size() * (SEGMENTS + 2))
	var k: int = 0
	var f: PackedFloat32Array = PackedFloat32Array([0.0])
	for c: int in centres.size():
		var at: Vector2 = centres[c]
		f[0] = radii[c]
		var r: float = f[0]  # the radius as the engine receives it (float)
		for i: int in SEGMENTS + 1:
			pts[k] = at + unit[i] * r
			k += 1
		pts[k] = at
		k += 1
	return pts


## Each circle's colour once per fan point (cached runs of SEGMENTS + 2, appended whole).
func colour_runs() -> PackedColorArray:
	var cols: PackedColorArray = PackedColorArray()
	if _runs.size() > RUNS_CAP:  # fading colours must not grow the cache without bound
		_runs.clear()
	for c: Color in colours:
		if not _runs.has(c):
			var run: PackedColorArray = PackedColorArray()
			@warning_ignore("return_value_discarded")
			run.resize(SEGMENTS + 2)
			run.fill(c)
			_runs[c] = run
		@warning_ignore("return_value_discarded")
		cols.append_array(_runs[c])
	return cols


## The fans' triangles for `n` circles (centre, rim i, rim i + 1): the same for every soak of
## that many circles, so it is built once up to the largest n and sliced.
static func indices(n: int) -> PackedInt32Array:
	var have: int = _idx.size() / (SEGMENTS * 3)
	@warning_ignore_start("return_value_discarded")
	for c: int in range(have, n):
		var base: int = c * (SEGMENTS + 2)
		for i: int in SEGMENTS:
			_idx.append(base + SEGMENTS + 1)
			_idx.append(base + i)
			_idx.append(base + i + 1)
	@warning_ignore_restore("return_value_discarded")
	return _idx.slice(0, n * SEGMENTS * 3)


## The engine's fan rim for a unit radius, each point through _rim()'s float32 steps.
static func _unit_rim() -> PackedVector2Array:
	if _unit.is_empty():
		var f: PackedFloat32Array = PackedFloat32Array([TAU / SEGMENTS, 0.0, 0.0])
		var step: float = f[0]  # the engine's real_t step
		for i: int in SEGMENTS + 1:
			@warning_ignore("return_value_discarded")
			_unit.append(_rim(f, i * step, 1.0))
	return _unit


## One rim point of the engine's fan in float32: (cos a * r, sin a * r).
static func _rim(f: PackedFloat32Array, angle: float, r: float) -> Vector2:
	f[0] = angle
	var a: float = f[0]
	f[0] = cos(a)
	f[1] = sin(a)
	f[0] = f[0] * r
	f[1] = f[1] * r
	return Vector2(f[0], f[1])
