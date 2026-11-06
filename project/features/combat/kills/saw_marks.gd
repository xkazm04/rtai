class_name SawMarks
extends RefCounted
## n7-melee: the chainsaw kill's read at 32 px/m (melee_marks.json `saw`, view only). The grind's
## drops stay hidden until they clear the held body (clear_m), the body judders by shake_m, and
## when the halves part a cream starburst edged in ink, release_m across, marks the kill frame.
## --feel=off (or a table that fails) gives the before: drops over the body, the old judder,
## no release burst.

const TABLE: String = "res://data/tables/melee_marks.json"
const SCHEMA: String = "gtai.melee_marks/1"
## The values before this pass (the before clips, and the fallback).
const BEFORE_SHAKE_M: float = 0.035
const RAYS: int = 7

static var _cached: SawMarks = null

var clear_m: float = 0.0
var shake_m: float = BEFORE_SHAKE_M
var release_m: float = 0.0


## The shipped marks (read once), or the before under --feel=off.
static func shipped() -> SawMarks:
	if _cached == null:
		_cached = load_from(TABLE, HitFeel.feel_flag() != "off")
	return _cached


## A cream starburst edged in ink (px), full size on the release frame, then shrinking (t 0..1).
static func burst(ci: CanvasItem, at: Vector2, r: float, turn: float, t: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in RAYS * 2:
		var k: float = 1.0 if i % 2 == 0 else (0.42 if i % 4 == 1 else 0.58)
		var a: float = turn + TAU * i / (RAYS * 2)
		@warning_ignore("return_value_discarded")
		pts.push_back(at + Vector2.from_angle(a) * r * k * (1.0 - 0.5 * t))
	var ring: PackedVector2Array = pts.duplicate()
	@warning_ignore("return_value_discarded")
	ring.push_back(pts[0])
	ci.draw_colored_polygon(pts, Color(KillSplitFx.CREAM, 1.0 - t * t))
	ci.draw_polyline(ring, Color(KillSplitFx.INK, 1.0 - t), 3.0, true)


static func load_from(path: String, enabled: bool) -> SawMarks:
	var m: SawMarks = SawMarks.new()
	if not enabled:
		return m
	var t: DataTable = DataTable.open(path, SCHEMA)
	if not t.ok():
		Log.error("melee_marks", str(t.errors()))
		return m
	var row: Dictionary = t.object(t.raw, "saw")
	m.clear_m = t.num(row, "clear_m")
	m.shake_m = t.num(row, "shake_m")
	m.release_m = t.num(row, "release_m")
	return m
