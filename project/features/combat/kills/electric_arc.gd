class_name ElectricArc
extends RefCounted
## One live current stroke for the wreck fx: a thin bright core inside a soft amber halo, jagged
## through a few kinks that re-jag every JAG_TICKS sim ticks, with one or two short side forks.
## No RNG: every offset is a hash of the serial, the arc's slot and the jag cell, so a replay
## draws the same shape and a still (reduced motion) holds the first one. Widths are screen
## pixels, so the stroke is as thin at 32 px/m as at 64.

const HALO: Color = Color("#edab42")
const CORE: Color = Color("#fffaf0")
const JAG_TICKS: int = 3
const KINK_TARGET: int = 5
const AMP_M: float = 0.075
const HALO_PX: float = 9.0
const MID_PX: float = 4.5
const CORE_PX: float = 2.0
const FORK_M: float = 0.24


## One polyline pass: its colour and width (px).
class Stroke:
	extends RefCounted
	var color: Color
	var width: float

	func _init(p_color: Color, p_width: float) -> void:
		color = p_color
		width = p_width


var seed_id: int = 0
var still: bool = false
var ppm: float = 32.0


func _init(p_seed: int, p_still: bool, p_ppm: float) -> void:
	seed_id = p_seed
	still = p_still
	ppm = p_ppm


static func cell(tick: int, frozen: bool) -> int:
	return 0 if frozen else tick / JAG_TICKS


## The jagged path through `points` (metres, at least two): the ends stay put, each segment is cut
## in pieces and the cuts (and the corners between) are pushed across the line.
static func shape(
	points: PackedVector2Array, serial: int, tick: int, frozen: bool
) -> PackedVector2Array:
	var jag: int = cell(tick, frozen)
	var segs: int = points.size() - 1
	var pieces: int = maxi(2, ceili(float(KINK_TARGET + 1) / float(segs)))
	var out: PackedVector2Array = PackedVector2Array([points[0]])
	var n: int = 0
	for s: int in segs:
		var a: Vector2 = points[s]
		var b: Vector2 = points[s + 1]
		var across: Vector2 = (b - a).orthogonal().normalized()
		for p: int in range(1, pieces + 1):
			var at: Vector2 = a.lerp(b, float(p) / float(pieces))
			var last: bool = s == segs - 1 and p == pieces
			if not last:
				at += across * (_h(serial, jag, n) - 0.5) * 2.0 * AMP_M
			n += 1
			@warning_ignore("return_value_discarded")
			out.append(at)
	return out


## Draw one arc (`slot` tells this wreck's arcs apart) at sim tick `tick`; `ci` is scaled by ppm.
func draw(ci: CanvasItem, points: PackedVector2Array, tick: int, slot: int) -> void:
	var serial: int = seed_id * 16 + slot
	var path: PackedVector2Array = shape(points, serial, tick, still)
	_stroke(ci, path, 1.0)
	for f: int in 2:
		var fork: PackedVector2Array = forks(path, serial, tick, still, f)
		if fork.size() > 1:
			_stroke(ci, fork, 0.55)


## Fork 0 always, fork 1 on a hash half the cells: a two-piece branch off a kink.
static func forks(
	path: PackedVector2Array, serial: int, tick: int, frozen: bool, f: int
) -> PackedVector2Array:
	var jag: int = cell(tick, frozen)
	if f == 1 and _h(serial, jag, 90) < 0.5:
		return PackedVector2Array()
	var k: int = 1 + int(_h(serial, jag, 70 + f) * float(path.size() - 2))
	var along: Vector2 = (path[k + 1] - path[k - 1]).normalized()
	var turn: float = (
		(1.0 if _h(serial, jag, 80 + f) < 0.5 else -1.0) * (0.6 + 0.5 * _h(serial, jag, 85 + f))
	)
	var dir: Vector2 = along.rotated(turn)
	var mid: Vector2 = path[k] + dir * FORK_M * 0.5
	return PackedVector2Array([path[k], mid, mid + dir.rotated(-turn * 0.7) * FORK_M * 0.5])


func _stroke(ci: CanvasItem, path: PackedVector2Array, k: float) -> void:
	for s: Stroke in strokes(k / ppm):
		ci.draw_polyline(path, s.color, s.width, true)


## The stroke look as data, widest first: two halo passes then the core, widths times `scale`
## (1/ppm inside a ppm-scaled canvas item, 1.0 in screen pixels). The one source of the look.
static func strokes(scale: float) -> Array[Stroke]:
	return [
		Stroke.new(Color(HALO, 0.18), HALO_PX * scale),
		Stroke.new(Color(HALO, 0.5), MID_PX * scale),
		Stroke.new(CORE, CORE_PX * scale),
	]


static func _h(a: int, b: int, c: int) -> float:
	return fposmod(
		sin(float(a) * 12.9898 + float(b) * 78.233 + float(c) * 37.719) * 43758.5453, 1.0
	)
