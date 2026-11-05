class_name DeflectMarks
extends RefCounted
## n7-melee: the plasma sword's deflect, made to read at 32 px/m (the audit's rank 2: a tiny spark
## on the blade, the returned round a thin line not tied to the swing). Listens to the view-only
## CombatArena.deflected and keeps the recent bats; FxView draws them on the print layer: on the
## bat frame a cream starburst edged in ink, and a cream streak running along the returned round,
## so the round reads as sent back by the swing. The look is data (melee_marks.json `deflect`);
## flash_ticks 0 or --feel=off = none (the before clips). Never read by the sim.

const TABLE: String = "res://data/tables/melee_marks.json"
const SCHEMA: String = "gtai.melee_marks/1"
const RAYS: int = 8
const KEEP: int = 8

var arena: CombatArena
var enabled: bool = true
var flash_ticks: int = 0
var burst_m: float = 0.0
var streak_m: float = 0.0
var streak_ticks: int = 0
## (at.x, at.y, back angle, tick) per bat, oldest first.
var marks: Array[Vector4] = []


static func attach(p_arena: CombatArena, path: String = TABLE) -> DeflectMarks:
	var m: DeflectMarks = DeflectMarks.new()
	m.arena = p_arena
	var t: DataTable = DataTable.open(path, SCHEMA)
	var row: Dictionary = t.object(t.raw, "deflect")
	m.flash_ticks = t.integer(row, "flash_ticks")
	m.burst_m = t.num(row, "burst_m")
	m.streak_m = t.num(row, "streak_m")
	m.streak_ticks = t.integer(row, "streak_ticks")
	m.enabled = HitFeel.feel_flag() != "off" and t.ok()
	if not t.ok():
		Log.error("melee_marks", str(t.errors()))
	@warning_ignore("return_value_discarded")
	p_arena.deflected.connect(m._on_deflected)
	return m


func _on_deflected(at: Vector2, back: Vector2) -> void:
	if not enabled or flash_ticks <= 0:
		return
	marks.append(Vector4(at.x, at.y, back.angle(), arena.tick))
	if marks.size() > KEEP:
		marks.remove_at(0)


func draw(ci: CanvasItem, tick: int) -> void:
	for m: Vector4 in marks:
		var age: int = tick - int(m.w)
		var at: Vector2 = Vector2(m.x, m.y)
		var back: Vector2 = Vector2.from_angle(m.z)
		if age >= 0 and age < streak_ticks:
			_streak(ci, at, back, float(age) / float(streak_ticks))
		if age >= 0 and age < flash_ticks:
			_burst(ci, at, m.z, float(age) / float(flash_ticks))


## A starburst of RAYS spikes, long and short by turns, full size on the bat frame, then shrinking.
func _burst(ci: CanvasItem, at: Vector2, turn: float, t: float) -> void:
	var r: float = burst_m * 0.5 * (1.0 - 0.5 * t)
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in RAYS * 2:
		var a: float = turn + TAU * i / (RAYS * 2)
		var k: float = 1.0 if i % 2 == 0 else (0.45 if i % 4 == 1 else 0.6)
		@warning_ignore("return_value_discarded")
		pts.push_back(Ink.px(at + Vector2.from_angle(a) * r * k))
	var ring: PackedVector2Array = pts.duplicate()
	@warning_ignore("return_value_discarded")
	ring.push_back(pts[0])
	ci.draw_colored_polygon(pts, Color(Ink.CREAM, 1.0 - t * t))
	ci.draw_polyline(ring, Color(Ink.INK, 1.0 - t), 3.0, true)


## The return: a cream line edged in ink from the bat point along the round, its tail catching up.
func _streak(ci: CanvasItem, at: Vector2, back: Vector2, t: float) -> void:
	var head: Vector2 = at + back * streak_m * minf(1.0, t * 3.0)
	var tail: Vector2 = at + back * streak_m * t
	ci.draw_line(Ink.px(tail), Ink.px(head), Color(Ink.INK, 1.0 - t), 7.0, true)
	ci.draw_line(Ink.px(tail), Ink.px(head), Color(Ink.CREAM, 1.0 - t), 3.0, true)
