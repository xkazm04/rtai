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
## False prints every circle with its own draw_circle (the old path, for A/B and evidence).
static var batched: bool = true

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
	var pts: PackedVector2Array = PackedVector2Array()
	var cols: PackedColorArray = PackedColorArray()
	var idx: PackedInt32Array = PackedInt32Array()
	var f: PackedFloat32Array = PackedFloat32Array([TAU / SEGMENTS, 0.0, 0.0])
	var step: float = f[0]  # the engine's real_t step
	@warning_ignore_start("return_value_discarded")
	for c: int in centres.size():
		var at: Vector2 = centres[c]
		f[1] = radii[c]
		var r: float = f[1]  # the radius as the engine receives it (float)
		var base: int = pts.size()
		for i: int in SEGMENTS + 1:
			pts.append(at + _rim(f, i * step, r))
		pts.append(at)
		for i: int in SEGMENTS + 2:
			cols.append(colours[c])
		for i: int in SEGMENTS:
			idx.append_array([base + SEGMENTS + 1, base + i, base + i + 1])
	@warning_ignore_restore("return_value_discarded")
	RenderingServer.canvas_item_add_triangle_array(ci.get_canvas_item(), idx, pts, cols)


## One rim point of the engine's fan in float32: (cos a * r, sin a * r).
static func _rim(f: PackedFloat32Array, angle: float, r: float) -> Vector2:
	f[0] = angle
	var a: float = f[0]
	f[0] = cos(a)
	f[1] = sin(a)
	f[0] = f[0] * r
	f[1] = f[1] * r
	return Vector2(f[0], f[1])
