class_name BladeMarks
extends RefCounted
## n31-melee 04b: one weapon's hit mark beside the claw's rakes (melee_marks.json `katana`,
## `plasma_sword`, `chainsaw`; drawn by ClawMarks, view only, never read by the sim). Styles:
## `cut` one thin straight line along the swing's tangent, ink edged with a cream highlight, and on
## a human a short red bead line welling up along it; `sear` the same line burnt in the plasma
## scorch's palette (a white-hot core cooling through ember to a dark char); `bite` the saw's kerf
## at the contact, a jagged ink stroke with a chattering cream starburst (SawMarks.burst) held on
## the victim while the grind holds. Full length on the hit frame (the hit-stop holds it).

const BEADS: int = 5
const TEETH: int = 7
## The bite sits this far from the victim's centre toward Rivet (the near side of the body).
const BITE_M: float = 0.2
## The teeth chatter for this share of the bite's life (the grind); the kerf fades over the rest.
const GRIND_FRAC: float = 0.6

var style: StringName = &""
var flash_ticks: int = 0
var cut_m: float = 0.0
var edge_px: float = 0.0
var core_px: float = 0.0
var blood_m: float = 0.0
var burst_m: float = 0.0
var tilt: float = 0.0


static func from_row(t: DataTable, row: Dictionary) -> BladeMarks:
	var b: BladeMarks = BladeMarks.new()
	b.style = StringName(t.text(row, "style"))
	b.flash_ticks = t.integer(row, "flash_ticks")
	b.cut_m = t.num(row, "cut_m")
	b.edge_px = t.num(row, "edge_px")
	b.core_px = t.num(row, "core_px")
	b.blood_m = t.num(row, "blood_m")
	b.burst_m = t.num(row, "burst_m")
	b.tilt = deg_to_rad(t.num(row, "tilt_deg"))
	return b


## The mark at `at` (metres) for a blow along `blow`, `age` ticks after the hit.
func draw(ci: CanvasItem, at: Vector2, blow: float, age: int, human: bool) -> void:
	var t: float = float(age) / float(maxi(flash_ticks, 1))
	var across: Vector2 = Vector2.from_angle(blow + PI * 0.5 + tilt)
	var p0: Vector2 = Ink.px(at - across * cut_m * 0.5)
	var p1: Vector2 = Ink.px(at + across * cut_m * 0.5)
	match style:
		&"cut":
			_cut(ci, p0, p1, t)
			if human and blood_m > 0.0:
				_beads(ci, at, blow, across, t)
		&"sear":
			_sear(ci, p0, p1, t)
		&"bite":
			_bite(ci, at, blow, across, age)


func _cut(ci: CanvasItem, p0: Vector2, p1: Vector2, t: float) -> void:
	var a: float = 1.0 - t * t
	var w: float = 1.0 - 0.4 * t
	ci.draw_line(p0, p1, Color(Ink.INK, a), edge_px * w, true)
	ci.draw_line(p0, p1, Color(Ink.CREAM, a), core_px * w, true)


## Red beads along the cut, a hair below it along the blow, welling up over the first third.
func _beads(ci: CanvasItem, at: Vector2, blow: float, across: Vector2, t: float) -> void:
	var grow: float = minf(t * 3.0, 1.0)
	var a: float = 1.0 - t * t * t
	var below: Vector2 = Vector2.from_angle(blow) * 0.03
	for i: int in BEADS:
		var k: float = (float(i) / float(BEADS - 1) - 0.5) * blood_m
		var p: Vector2 = Ink.px(at + below + across * k)
		var r: float = (1.2 + 1.3 * grow) * (0.7 + 0.3 * float((i * 7) % 3))
		ci.draw_circle(p, r, Color(KillMarkArt.BLOOD, a))


## The plasma cut: an ember heat bloom and a white-hot core that cools to ember then to a dark sear.
func _sear(ci: CanvasItem, p0: Vector2, p1: Vector2, t: float) -> void:
	var hot: float = clampf(t * 2.0, 0.0, 1.0)
	var cool: float = clampf(t * 2.0 - 1.0, 0.0, 1.0)
	var core: Color = KillHoleFx.HOT.lerp(KillHoleFx.EMBER, hot).lerp(PlasmaScorchView.CHAR, cool)
	var a: float = 1.0 - t * t * t
	ci.draw_line(p0, p1, Color(KillHoleFx.EMBER, 0.55 * (1.0 - hot)), edge_px * 2.2, true)
	ci.draw_line(p0, p1, Color(Ink.INK, a), edge_px, true)
	ci.draw_line(p0, p1, Color(core, a), core_px * (1.0 - 0.3 * cool), true)


## The saw's bite: a jagged kerf across the contact and a chattering burst on the teeth.
func _bite(ci: CanvasItem, at: Vector2, blow: float, across: Vector2, age: int) -> void:
	var along: Vector2 = Vector2.from_angle(blow)
	var bite: Vector2 = at - along * BITE_M
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in TEETH:
		var k: float = float(i) / float(TEETH - 1) - 0.5
		var jag: float = 0.04 * (1.0 if (i + age / 3) % 2 == 0 else -1.0)
		@warning_ignore("return_value_discarded")
		pts.push_back(Ink.px(bite + across * k * cut_m + along * jag))
	var a: float = 1.0 - 0.6 * float(age) / float(maxi(flash_ticks, 1))
	ci.draw_polyline(pts, Color(Ink.INK, a), edge_px, true)
	ci.draw_polyline(pts, Color(Ink.CREAM, a), core_px, true)
	if age > int(float(flash_ticks) * GRIND_FRAC):
		return
	var chatter: float = float(age % 4) / 4.0
	var r: float = burst_m * Ink.PX_PER_M * (0.8 + 0.2 * chatter)
	SawMarks.burst(ci, Ink.px(bite), r, float(age) * 0.9, 0.3 * chatter)
