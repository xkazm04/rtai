class_name KillOverloadArcs
extends RefCounted
## n31 melee 04g: the baton overload's live current, drawn by code OVER his body (the drawn jolt
## rows carry only 1 px cream lines, which the print flattens to grey at 32 px/m). `arc_n` amber
## arcs (ElectricArc's jag: no RNG, re-jags every 3 ticks, held still under reduced motion) run
## from the baton's contact on his chest to his head, both hands and the ground, from the kill
## tick until the row's `arc_ticks` (its cells_at plus a short tail, fading over TAIL_TICKS), with
## an amber-white flash on the contact for FLASH_TICKS. Widths are screen px. Amber = current.

const MAX_ARCS: int = 4
const FLASH_TICKS: int = 3
const TAIL_TICKS: int = 4
## Where each arc ends on the posed figure: (up the body 0 feet..1 head, metres across). The
## first reaches the head, two the hands, the last runs past the feet into the ground.
const ENDS: PackedVector2Array = [
	Vector2(0.93, 0.05), Vector2(0.5, -0.34), Vector2(0.46, 0.36), Vector2(-0.04, -0.3)
]
## The contact: this high up his figure, this many metres back along the blow (toward Rivet).
const CONTACT_UP: float = 0.62
const CONTACT_BACK_M: float = 0.16
## The stroke, screen px, widest first: a soft halo, the solid amber body, a thin cream core.
const HALO_PX: float = 7.0
const AMBER_PX: float = 4.0
const CORE_PX: float = 1.5


## The arcs the row draws (fx `arc_n`, 0..MAX_ARCS; 0 = none).
static func count(extra: KillTrackRows.Extra) -> int:
	return clampi(roundi(extra.num("arc_n", 0.0)), 0, MAX_ARCS)


## The tick the current dies (fx `arc_ticks`; else the row's cells_at plus the tail).
static func ticks(extra: KillTrackRows.Extra) -> int:
	return roundi(extra.num("arc_ticks", extra.num("cells_at", 0.0) + float(TAIL_TICKS)))


## The current is live on the kill tick and until `ticks`.
static func live(extra: KillTrackRows.Extra, age: int) -> bool:
	return count(extra) > 0 and age >= 0 and age < ticks(extra)


## 1 while live, fading to 0 over the last TAIL_TICKS.
static func fade(extra: KillTrackRows.Extra, age: int) -> float:
	if not live(extra, age):
		return 0.0
	return clampf(float(ticks(extra) - age) / float(TAIL_TICKS), 0.0, 1.0)


## The contact point (layer px): on his chest, back along the blow toward the baton.
static func contact(d: KillNewStyles.Death, ppm: float) -> Vector2:
	return _at(d, CONTACT_UP, 0.0, ppm) - d.dir * CONTACT_BACK_M * ppm


## Each arc's two ends in layer px: the contact, then its limb (count(extra) of them).
static func ends(d: KillNewStyles.Death, ppm: float) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	var from: Vector2 = contact(d, ppm)
	for i: int in count(d.extra):
		out.append(PackedVector2Array([from, _at(d, ENDS[i].x, ENDS[i].y, ppm)]))
	return out


static func draw(ci: KillNewStyles, d: KillNewStyles.Death, age: int) -> void:
	var a: float = fade(d.extra, age)
	if a <= 0.0:
		return
	var ppm: float = maxf(1.0, ci.ppm)
	var slot: int = 0
	for pair: PackedVector2Array in ends(d, ppm):
		var m: PackedVector2Array = PackedVector2Array([pair[0] / ppm, pair[1] / ppm])
		var path: PackedVector2Array = ElectricArc.shape(
			m, d.serial * 16 + slot, age, ci.reduced_motion
		)
		for i: int in path.size():  # ElectricArc jags in metres; drawn in layer px
			path[i] *= ppm
		for s: ElectricArc.Stroke in strokes(1.0, a):
			ci.draw_polyline(path, s.color, s.width, true)
		slot += 1
	if age < FLASH_TICKS and not ci.reduced_motion:
		var c: Vector2 = contact(d, ppm)
		ci.draw_circle(c, ppm * 0.3, Color(ElectricArc.HALO, 0.55))
		ci.draw_circle(c, ppm * 0.12, ElectricArc.CORE)


## The stroke passes, widest first, widths times `scale`, alpha times `a`.
static func strokes(scale: float, a: float) -> Array[ElectricArc.Stroke]:
	return [
		ElectricArc.Stroke.new(Color(ElectricArc.HALO, 0.25 * a), HALO_PX * scale),
		ElectricArc.Stroke.new(Color(ElectricArc.HALO, 0.95 * a), AMBER_PX * scale),
		ElectricArc.Stroke.new(Color(ElectricArc.CORE, a), CORE_PX * scale),
	]


static func _at(d: KillNewStyles.Death, up: float, side: float, ppm: float) -> Vector2:
	var axis: Vector2 = d.head_px - d.feet_px
	var across: Vector2 = axis.normalized().orthogonal() if axis != Vector2.ZERO else Vector2.RIGHT
	return d.feet_px + axis * up + across * side * ppm
